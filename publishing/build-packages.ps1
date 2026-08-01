[CmdletBinding()]
param(
    [string] $OutputDirectory = "dist",
    [string[]] $Package = @(),
    [string] $OpenScadPath = "C:\Program Files\OpenSCAD\openscad.com",
    [switch] $SkipOpenScadVerification,
    [switch] $KeepStaging
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$publishingRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repositoryRoot = Split-Path -Parent $publishingRoot
$manifestRoot = Join-Path $publishingRoot "packages"
$resolvedOutput = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $OutputDirectory))
$repositoryPath = [System.IO.Path]::GetFullPath($repositoryRoot)

if (!$resolvedOutput.StartsWith($repositoryPath, [System.StringComparison]::OrdinalIgnoreCase))
{
    throw "Output directory must remain inside the repository: $resolvedOutput"
}

function Invoke-GitText
{
    param([Parameter(Mandatory = $true)][string[]] $Arguments)

    $text = & git -C $repositoryRoot @Arguments
    if ($LASTEXITCODE -ne 0)
    {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
    return ($text | Out-String).Trim()
}

function Get-CoreVersion
{
    $core = Get-Content -LiteralPath (Join-Path $repositoryRoot "LogoSC-Foundation-Core.scad") -Raw
    $major = [regex]::Match($core, 'LogoSCVersionMajor\s*=\s*(\d+)').Groups[1].Value
    $minor = [regex]::Match($core, 'LogoSCVersionMinor\s*=\s*(\d+)').Groups[1].Value
    if (!$major -or !$minor)
    {
        throw "Unable to read LogoSCVersionMajor and LogoSCVersionMinor from Core."
    }
    return "$major.$minor"
}

function Copy-PackageFile
{
    param(
        [Parameter(Mandatory = $true)][string] $SourceRelative,
        [Parameter(Mandatory = $true)][string] $DestinationRelative,
        [Parameter(Mandatory = $true)][string] $StageRoot
    )

    $source = Join-Path $repositoryRoot $SourceRelative
    if (!(Test-Path -LiteralPath $source -PathType Leaf))
    {
        throw "Required package file is missing: $SourceRelative"
    }

    $destination = Join-Path $StageRoot $DestinationRelative
    $destinationDirectory = Split-Path -Parent $destination
    if (!(Test-Path -LiteralPath $destinationDirectory))
    {
        New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    }
    Copy-Item -LiteralPath $source -Destination $destination -Force
}

function Test-ScadDependencies
{
    param([Parameter(Mandatory = $true)][string] $StageRoot)

    $missing = [System.Collections.Generic.List[string]]::new()
    Get-ChildItem -LiteralPath $StageRoot -Filter "*.scad" -File -Recurse | ForEach-Object {
        $scadFile = $_
        $scadText = Get-Content -LiteralPath $scadFile.FullName -Raw
        [regex]::Matches($scadText, '(?m)^\s*(?:include|use)\s*<([^>]+)>') | ForEach-Object {
            $dependency = $_.Groups[1].Value
            $localDependency = Join-Path $scadFile.DirectoryName $dependency
            $rootDependency = Join-Path $StageRoot $dependency
            if (!(Test-Path -LiteralPath $localDependency) -and !(Test-Path -LiteralPath $rootDependency))
            {
                $missing.Add("$($scadFile.Name) -> $dependency")
            }
        }
    }
    if ($missing.Count -gt 0)
    {
        throw "Missing OpenSCAD dependencies:`n$($missing -join [Environment]::NewLine)"
    }
}

function Test-MarkdownAssets
{
    param([Parameter(Mandatory = $true)][string] $StageRoot)

    $missing = [System.Collections.Generic.List[string]]::new()
    Get-ChildItem -LiteralPath $StageRoot -Filter "*.md" -File -Recurse | ForEach-Object {
        $markdownFile = $_
        $markdown = Get-Content -LiteralPath $markdownFile.FullName -Raw
        [regex]::Matches($markdown, '!\[[^\]]*\]\(([^)]+)\)') | ForEach-Object {
            $target = $_.Groups[1].Value.Trim()
            if ($target -notmatch '^(?:https?:|data:|#)')
            {
                $asset = Join-Path $markdownFile.DirectoryName $target
                if (!(Test-Path -LiteralPath $asset))
                {
                    $missing.Add("$($markdownFile.Name) -> $target")
                }
            }
        }
    }
    if ($missing.Count -gt 0)
    {
        throw "Missing Markdown image assets:`n$($missing -join [Environment]::NewLine)"
    }
}

function Resolve-PackagedMarkdownLinks
{
    param([Parameter(Mandatory = $true)][string] $StageRoot)

    Get-ChildItem -LiteralPath $StageRoot -Filter "*.md" -File -Recurse | ForEach-Object {
        $markdownFile = $_
        $markdown = [System.IO.File]::ReadAllText($markdownFile.FullName)
        $updated = [regex]::Replace(
            $markdown,
            '(?<!!)\[([^\]]+)\]\(([^)]+)\)',
            {
                param($match)

                $label = $match.Groups[1].Value
                $target = $match.Groups[2].Value.Trim()
                if ($target -match '^(?:https?:|mailto:|data:|#)')
                {
                    return $match.Value
                }

                $hashIndex = $target.IndexOf("#")
                $pathPart = $target
                $anchorPart = ""
                if ($hashIndex -ge 0)
                {
                    $pathPart = $target.Substring(0, $hashIndex)
                    $anchorPart = $target.Substring($hashIndex)
                }
                if (!$pathPart)
                {
                    return $match.Value
                }

                $localTarget = Join-Path $markdownFile.DirectoryName $pathPart
                if (Test-Path -LiteralPath $localTarget)
                {
                    return $match.Value
                }

                $repositoryRelative = $pathPart.Replace("\", "/").TrimStart([char[]] @(".", "/"))
                $externalTarget =
                    "https://github.com/jbrad8254/LogoSC/blob/$commit/$repositoryRelative$anchorPart"
                return "[$label]($externalTarget)"
            }
        )
        if ($updated -ne $markdown)
        {
            [System.IO.File]::WriteAllText(
                $markdownFile.FullName,
                $updated,
                [System.Text.UTF8Encoding]::new($false)
            )
        }
    }
}

function Test-MarkdownLinks
{
    param([Parameter(Mandatory = $true)][string] $StageRoot)

    $missing = [System.Collections.Generic.List[string]]::new()
    Get-ChildItem -LiteralPath $StageRoot -Filter "*.md" -File -Recurse | ForEach-Object {
        $markdownFile = $_
        $markdown = Get-Content -LiteralPath $markdownFile.FullName -Raw
        [regex]::Matches($markdown, '(?<!!)\[[^\]]+\]\(([^)]+)\)') | ForEach-Object {
            $target = $_.Groups[1].Value.Trim()
            if ($target -notmatch '^(?:https?:|mailto:|data:|#)')
            {
                $pathPart = $target.Split("#")[0]
                if ($pathPart -and !(Test-Path -LiteralPath (Join-Path $markdownFile.DirectoryName $pathPart)))
                {
                    $missing.Add("$($markdownFile.Name) -> $target")
                }
            }
        }
    }
    if ($missing.Count -gt 0)
    {
        throw "Missing local Markdown links:`n$($missing -join [Environment]::NewLine)"
    }
}

function Invoke-PackageOpenScadCheck
{
    param(
        [Parameter(Mandatory = $true)][string] $CheckName,
        [Parameter(Mandatory = $true)][string] $InputFile,
        [Parameter(Mandatory = $true)][string] $OutputFile,
        [string[]] $DefineList = @(),
        [string] $RequiredMarker = ""
    )

    $argumentList = @()
    foreach ($define in $DefineList)
    {
        $argumentList += @("-D", $define)
    }
    $argumentList += @("-o", $OutputFile, $InputFile)

    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $log = @(& $OpenScadPath @argumentList 2>&1)
    $exitCode = $LASTEXITCODE
    $timer.Stop()

    $logPath = [System.IO.Path]::ChangeExtension($OutputFile, ".log")
    [System.IO.File]::WriteAllLines(
        $logPath,
        [string[]] $log,
        [System.Text.UTF8Encoding]::new($false)
    )

    if ($exitCode -ne 0)
    {
        throw "$CheckName failed with exit code $exitCode. See $logPath"
    }
    if ($RequiredMarker -and !(($log -join "`n").Contains($RequiredMarker)))
    {
        throw "$CheckName did not emit required marker $RequiredMarker. See $logPath"
    }

    return [PSCustomObject]@{
        Check = $CheckName
        Seconds = [math]::Round($timer.Elapsed.TotalSeconds, 2)
        OutputBytes = (Get-Item -LiteralPath $OutputFile).Length
        Result = "PASS"
        Log = [System.IO.Path]::GetFileName($logPath)
    }
}

function New-PortableZip
{
    param(
        [Parameter(Mandatory = $true)][string] $SourceDirectory,
        [Parameter(Mandatory = $true)][string] $ArchivePath
    )

    $archiveStream = [System.IO.File]::Open(
        $ArchivePath,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::Write,
        [System.IO.FileShare]::None
    )
    try
    {
        $archive = [System.IO.Compression.ZipArchive]::new(
            $archiveStream,
            [System.IO.Compression.ZipArchiveMode]::Create,
            $true
        )
        try
        {
            Get-ChildItem -LiteralPath $SourceDirectory -File -Recurse | Sort-Object FullName |
                ForEach-Object {
                    $entryName = $_.FullName.Substring($SourceDirectory.Length + 1).Replace("\", "/")
                    $entry = $archive.CreateEntry(
                        $entryName,
                        [System.IO.Compression.CompressionLevel]::Optimal
                    )
                    $entryStream = $entry.Open()
                    $sourceStream = [System.IO.File]::OpenRead($_.FullName)
                    try
                    {
                        $sourceStream.CopyTo($entryStream)
                    }
                    finally
                    {
                        $sourceStream.Dispose()
                        $entryStream.Dispose()
                    }
                }
        }
        finally
        {
            $archive.Dispose()
        }
    }
    finally
    {
        $archiveStream.Dispose()
    }
}

$coreVersion = Get-CoreVersion
$commit = Invoke-GitText -Arguments @("rev-parse", "HEAD")
$shortCommit = Invoke-GitText -Arguments @("rev-parse", "--short=8", "HEAD")
$tag = (& git -C $repositoryRoot tag --points-at HEAD | Select-Object -First 1 | Out-String).Trim()
$dirty = [bool](Invoke-GitText -Arguments @("status", "--porcelain"))

if ($tag -and !$dirty)
{
    if ($tag -ne "v$coreVersion")
    {
        throw "Clean release tag $tag does not match Core version v$coreVersion."
    }
    $releaseIdentity = $tag.TrimStart("v")
    $sourceState = "clean tagged commit $tag"
}
else
{
    $dirtySuffix = ""
    if ($dirty)
    {
        $dirtySuffix = "-dirty"
    }
    $releaseIdentity = "$coreVersion-unreleased-$shortCommit$dirtySuffix"
    $sourceState = "working tree based on $commit$(if ($dirty) { ' with uncommitted changes' })"
}

if (Test-Path -LiteralPath $resolvedOutput)
{
    $resolvedOutputPath = [System.IO.Path]::GetFullPath($resolvedOutput)
    if (!$resolvedOutputPath.StartsWith($repositoryPath, [System.StringComparison]::OrdinalIgnoreCase))
    {
        throw "Refusing to remove unexpected output path: $resolvedOutputPath"
    }
    Remove-Item -LiteralPath $resolvedOutputPath -Recurse -Force
}
New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null

$verificationRoot = Join-Path $resolvedOutput "verification"
if (!$SkipOpenScadVerification)
{
    if (!(Test-Path -LiteralPath $OpenScadPath -PathType Leaf))
    {
        throw "OpenSCAD verification executable not found: $OpenScadPath"
    }
    New-Item -ItemType Directory -Path $verificationRoot -Force | Out-Null
}

$manifestFiles = Get-ChildItem -LiteralPath $manifestRoot -Filter "*.json" -File | Sort-Object Name
if ($Package.Count -gt 0)
{
    $requested = [System.Collections.Generic.HashSet[string]]::new(
        [string[]] $Package,
        [System.StringComparer]::OrdinalIgnoreCase
    )
    $manifestFiles = $manifestFiles | Where-Object {
        $candidate = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json
        $requested.Contains([string] $candidate.key)
    }
}

if (@($manifestFiles).Count -eq 0)
{
    throw "No package manifests selected."
}

$results = [System.Collections.Generic.List[object]]::new()
$verificationResults = [System.Collections.Generic.List[object]]::new()

foreach ($manifestFile in $manifestFiles)
{
    $manifest = Get-Content -LiteralPath $manifestFile.FullName -Raw | ConvertFrom-Json
    $stageRoot = Join-Path $resolvedOutput ("stage-" + $manifest.key)
    New-Item -ItemType Directory -Path $stageRoot -Force | Out-Null

    Copy-PackageFile -SourceRelative $manifest.readmeSource -DestinationRelative "README.md" `
        -StageRoot $stageRoot
    Copy-PackageFile -SourceRelative "LICENSE" -DestinationRelative "LICENSE" -StageRoot $stageRoot
    Copy-PackageFile -SourceRelative "LogoSC-Suite-Guide.md" `
        -DestinationRelative "LogoSC-Suite-Guide.md" -StageRoot $stageRoot
    Copy-PackageFile -SourceRelative $manifest.thingiverseDescription `
        -DestinationRelative "thingiverse/THINGIVERSE-DESCRIPTION.md" -StageRoot $stageRoot
    Copy-PackageFile -SourceRelative $manifest.thingiverseCover `
        -DestinationRelative "thingiverse/cover.png" -StageRoot $stageRoot

    foreach ($sourceRelative in $manifest.files)
    {
        $destinationRelative = [string] $sourceRelative
        $renameProperty = $manifest.renames.PSObject.Properties |
            Where-Object { $_.Name -eq $sourceRelative } |
            Select-Object -First 1
        if ($null -ne $renameProperty)
        {
            $destinationRelative = [string] $renameProperty.Value
        }
        Copy-PackageFile -SourceRelative $sourceRelative -DestinationRelative $destinationRelative `
            -StageRoot $stageRoot
    }

    Get-ChildItem -LiteralPath (Join-Path $repositoryRoot "images") -Filter "*.png" -File |
        Sort-Object Name | ForEach-Object {
            Copy-PackageFile -SourceRelative ("images/" + $_.Name) `
                -DestinationRelative ("images/" + $_.Name) -StageRoot $stageRoot
        }

    Resolve-PackagedMarkdownLinks -StageRoot $stageRoot

    $versionText = @(
        "LogoSC release: $releaseIdentity"
        "Package: $($manifest.name)"
        "Source commit: $commit"
        "Source state: $sourceState"
        "Repository: https://github.com/jbrad8254/LogoSC"
        "Bug reports: https://github.com/jbrad8254/LogoSC/issues"
    ) -join "`n"
    [System.IO.File]::WriteAllText(
        (Join-Path $stageRoot "LogoSC-Version.txt"),
        $versionText + "`n",
        [System.Text.UTF8Encoding]::new($false)
    )

    Test-ScadDependencies -StageRoot $stageRoot
    Test-MarkdownAssets -StageRoot $stageRoot
    Test-MarkdownLinks -StageRoot $stageRoot

    foreach ($entryPoint in $manifest.entryPoints)
    {
        if (!(Test-Path -LiteralPath (Join-Path $stageRoot $entryPoint) -PathType Leaf))
        {
            throw "$($manifest.name) entry point is missing: $entryPoint"
        }
    }

    if (!$SkipOpenScadVerification)
    {
        foreach ($verification in $manifest.verification)
        {
            $verificationName = "$($manifest.key)-$($verification.name)"
            $verificationOutput = Join-Path $verificationRoot ($verificationName + ".csg")
            $verificationResult = Invoke-PackageOpenScadCheck `
                -CheckName $verificationName `
                -InputFile (Join-Path $stageRoot $verification.input) `
                -OutputFile $verificationOutput `
                -DefineList ([string[]] $verification.defines) `
                -RequiredMarker ([string] $verification.requiredMarker)
            $verificationResults.Add($verificationResult)
        }
    }

    $inventory = Get-ChildItem -LiteralPath $stageRoot -File -Recurse |
        ForEach-Object { $_.FullName.Substring($stageRoot.Length + 1).Replace("\", "/") } |
        Sort-Object
    [System.IO.File]::WriteAllLines(
        (Join-Path $stageRoot "PACKAGE-CONTENTS.txt"),
        [string[]] $inventory,
        [System.Text.UTF8Encoding]::new($false)
    )

    $archiveName = "$($manifest.archiveSlug)-v$releaseIdentity.zip"
    $archivePath = Join-Path $resolvedOutput $archiveName
    New-PortableZip -SourceDirectory $stageRoot -ArchivePath $archivePath
    $hash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    $results.Add([PSCustomObject]@{
        Package = $manifest.name
        Archive = $archiveName
        Files = @(Get-ChildItem -LiteralPath $stageRoot -File -Recurse).Count
        Bytes = (Get-Item -LiteralPath $archivePath).Length
        SHA256 = $hash
    })

    if (!$KeepStaging)
    {
        Remove-Item -LiteralPath $stageRoot -Recurse -Force
    }
}

$reportPath = Join-Path $resolvedOutput "LogoSC-Package-Report.json"
$reportJson = $results | ConvertTo-Json -Depth 4
[System.IO.File]::WriteAllText(
    $reportPath,
    $reportJson + "`n",
    [System.Text.UTF8Encoding]::new($false)
)

if (!$SkipOpenScadVerification)
{
    $verificationReportPath = Join-Path $resolvedOutput "LogoSC-Verification-Report.json"
    $verificationJson = $verificationResults | ConvertTo-Json -Depth 4
    [System.IO.File]::WriteAllText(
        $verificationReportPath,
        $verificationJson + "`n",
        [System.Text.UTF8Encoding]::new($false)
    )
    $verificationResults | Format-Table -AutoSize
    Write-Output "Verification report: $verificationReportPath"
}
$results | Format-Table -AutoSize
Write-Output "Package report: $reportPath"

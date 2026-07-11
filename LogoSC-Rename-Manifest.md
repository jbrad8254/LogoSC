# LogoSC Rename Manifest

This update renames the project from **LogoT** to **LogoSC**.

## Required Git cleanup

ZIP extraction cannot delete tracked files. After extracting this update over
the repository, delete these old files:

- `LogoT-ARC-Implementation.md`
- `LogoT-CheatSheet.md`
- `LogoT-Developer-Notebook.md`
- `LogoT-Examples.scad`
- `LogoT-Experiments.scad`
- `LogoT-Foundation-Core.scad`
- `LogoT-Foundation-Tests.scad`
- `LogoT-Future-Context.md`
- `LogoT-Holes-Implementation.md`
- `LogoT-LSystems-Notes.md`
- `LogoT-README.md`
- `LogoT-User-Manual.md`

The corresponding `LogoSC-*` files are included in this archive. GitHub Desktop
or Git should usually detect these delete/add pairs as renames.

After committing and verifying the source rename, rename the GitHub repository
from `LogoT` to `LogoSC`.

Generic APIs remain unchanged; only project/file names and symbols explicitly
containing `LogoT` were renamed.

# Introducing LogoSC to the OpenSCAD Community

This is the persistent submission playbook for introducing LogoSC to OpenSCAD users and
maintainers. It is not a storefront description or release package. Use it after the next knot
work is complete, the release candidate has a stable tag, and the fresh verification evidence is
ready to link.

LogoSC's durable public home should remain its
[GitHub repository](https://github.com/jbrad8254/LogoSC). Community posts should point there
rather than trying to reproduce the project in a forum attachment.

## Table of contents

- [Recommendation](#recommendation)
- [Where to introduce LogoSC](#where-to-introduce-logosc)
- [Suggested submission sequence](#suggested-submission-sequence)
- [What to have ready](#what-to-have-ready)
- [How to position the project](#how-to-position-the-project)
- [How to discuss the AI contribution](#how-to-discuss-the-ai-contribution)
- [Draft primary introduction](#draft-primary-introduction)
- [Shorter announcement](#shorter-announcement)
- [Possible Libraries-page request](#possible-libraries-page-request)
- [Questions to ask the community](#questions-to-ask-the-community)
- [Handling responses](#handling-responses)
- [Final checklist](#final-checklist)
- [Current community references](#current-community-references)

## Recommendation

Use a staged introduction rather than posting identical promotional text everywhere at once:

1. Make one substantive announcement on the official OpenSCAD discussion mailing list.
2. Stay in that thread, answer technical questions, and incorporate worthwhile feedback.
3. Mention the thread in `#openscad` on Libera.Chat if real-time discussion would help.
4. Post a shorter visual introduction to `r/openscad` and optionally the official social accounts.
5. After community review and a stable tagged release, ask whether LogoSC is appropriate for the
   official OpenSCAD Libraries page and what maintainers want in a listing proposal.

The mailing list is the best first venue because the official community page describes it as the
place for OpenSCAD usage, problems, and development discussion. LogoSC is engineering work and a
reusable library, not merely one printable object, so a technical discussion is more appropriate
than a Thingiverse-first launch.

Do **not** open an issue against the OpenSCAD application merely to announce LogoSC. The OpenSCAD
issue tracker is for application bugs and feature requests. A LogoSC issue belongs there only if
the project exposes a reproducible OpenSCAD defect or motivates a concrete OpenSCAD feature
request.

## Where to introduce LogoSC

- **[OpenSCAD mailing list](https://lists.openscad.org/list/discuss.lists.openscad.org):** The
  primary venue for a technical introduction, design feedback, compatibility discussion, and
  maintainer visibility. Post here first. Subscribe early because confirmation and moderator
  acceptance can take time. Send plain text by email rather than relying on the archive's web
  composer.
- **[`#openscad` on Libera.Chat](https://web.libera.chat/#openscad):** Useful for informal
  follow-up, quick questions, and finding interested reviewers. Link the durable mailing-list
  thread and repository; do not paste the entire announcement into chat.
- **[OpenSCAD subreddit](https://www.reddit.com/r/openscad/):** Appropriate for a visual
  demonstration, broader user feedback, and discussion of AI-assisted OpenSCAD work. Use one
  strong gallery image and link to the repository and technical announcement.
- **[Official OpenSCAD social accounts](https://openscad.org/community.html#social-media):** An
  optional way to amplify a stable release after the technical introduction has settled.
- **[Official OpenSCAD Libraries page](https://openscad.org/libraries.html):** The best long-term
  discovery target for a maintained reusable library. Treat it as a later curation request, not
  an automatic submission channel. Ask maintainers first.
- **[OpenSCAD website repository](https://github.com/openscad/openscad.github.com):** This contains
  the source of the Libraries page. Do not submit a surprise listing. Discuss suitability and
  expected metadata before editing `libraries.html`.
- **Thingiverse or other model sites:** Useful only for individual printable demonstrations. Link
  representative models back to the library; do not make a model page the canonical engineering
  record.

The official community page also lists an OpenSCAD Thingiverse group and Facebook community. They
may be useful later, but they are not necessary for the first technical introduction.

## Suggested submission sequence

### 1. Prepare a release candidate

Finish the planned knot work, settle the release contents, and create the normal release only when
authorized. Before announcing:

- use one immutable release tag or GitHub release URL;
- make the root README lead quickly to installation and a small runnable example;
- make the license, supported OpenSCAD version, known limitations, and compatibility assumptions
  easy to find;
- rerun the complete acceptance wall and preserve its summary;
- render the public galleries from the tagged source; and
- verify that the links in the announcement resolve without requiring repository knowledge.

Avoid announcing a moving branch as if it were a finished release. It is fine to say "release
candidate" and request review, but make that status explicit.

### 2. Send the mailing-list introduction

Use a subject that is memorable but still tells readers what the project is. Recommended:

> LogoSC: I wanted to make a screw and accidentally built a turtle-geometry language

Keep the message self-contained, but link outward for detail. Include one repository link, one
overview or manual link, one provenance link, and at most a few image links. Do not attach a large
ZIP or paste thousands of lines of `.scad` source into email.

### 3. Invite review, not endorsement

Ask concrete technical questions. The goal of the first post is to find users who will try the
library, identify unidiomatic OpenSCAD choices, and say whether it fills a useful niche. Do not ask
for immediate inclusion on the official Libraries page in the opening paragraph.

### 4. Follow up where useful

After the primary thread exists:

- mention it on IRC and ask whether anyone wants to test a specific platform or OpenSCAD build;
- create a shorter `r/openscad` post centered on the gallery and a five-line explanation;
- update the repository when feedback produces a real correction; and
- summarize material changes back in the original thread rather than starting several fragmented
  discussions.

### 5. Ask about official library discovery

Once the API and release are stable, ask in the original discussion whether LogoSC belongs under
"General" or "Single Topic" on the official Libraries page. LogoSC is arguably a general 2D
geometry DSL with optional focused companions; the maintainers may prefer a narrower description.
Follow their classification rather than arguing from the project's internal suite structure.

## What to have ready

The submission should make independent evaluation easy. Prepare these links and facts:

- **Repository:** <https://github.com/jbrad8254/LogoSC>
- **Release:** a stable tag or GitHub release, not only `main`
- **License:** MIT, linked directly to [`LICENSE`](../../LICENSE)
- **Quick start:** [`README.md`](../../README.md) and a small standalone `.scad` example
- **Detailed API:** [`LogoSC-User-Manual.md`](../../LogoSC-User-Manual.md)
- **Compact reference:** [`LogoSC-CheatSheet.md`](../../LogoSC-CheatSheet.md)
- **AI provenance:** [`LogoSC-Development-Provenance.md`](../../LogoSC-Development-Provenance.md)
- **Contributing and expectations:** [`CONTRIBUTING.md`](../../CONTRIBUTING.md)
- **Verification instructions:**
  [`LogoSC-OpenSCAD-Command-Line.md`](../../LogoSC-OpenSCAD-Command-Line.md)
- **Representative images:** the main examples, validation/debug, L-system, knots, and fastener
  galleries, chosen sparingly
- **Fresh test summary:** suite names, pass counts, OpenSCAD version, operating system, and exact
  command used
- **Known limitations:** especially that LogoSC Core creates 2D polygonal regions and leaves 3D
  composition to native OpenSCAD

Recommended first-post images are
[`examples-gallery.png`](../../images/examples-gallery.png) and one specialized gallery such as
[`l-system-gallery.png`](../../images/l-system-gallery.png). More images can make the announcement
feel like a catalog instead of an engineering introduction.

## How to position the project

Lead with the boundary that makes LogoSC understandable:

> LogoSC is a small Logo-inspired turtle geometry layer for OpenSCAD. It evaluates compact command
> lists into reusable 2D polygonal regions; native OpenSCAD remains responsible for extrusion,
> booleans, placement, materials, and ordinary 3D composition.

Useful points to emphasize:

- It is a library and domain-specific geometry layer, not a replacement OpenSCAD parser and not a
  claim to implement the full Logo language.
- Core is intentionally 2D and composable with normal OpenSCAD operations.
- The public API includes rendering, path/region evaluation, debug visualization, validation,
  holes, reusable command lists, and affine turtle transforms.
- Optional companions demonstrate more ambitious use: knots and Celtic structures, printable
  fasteners, and deterministic or seeded L-systems.
- The repository includes runnable examples, focused companions, extensive documentation, and
  machine-readable test summaries.
- Design decisions and non-goals are documented rather than hidden in generated code.

Avoid describing every companion in the first sentence. Readers should understand Core before
they encounter knots, screws, or L-systems.

## How to discuss the AI contribution

Be direct: LogoSC is heavily AI-derived. The design and code were developed through sustained
human direction and review with substantial work performed by OpenAI language-model tools. The
disclosure should be prominent enough that nobody feels it was concealed, but it should not turn
the entire technical introduction into an argument about AI.

Suggested wording:

> This project is heavily AI-assisted. I set the goals, API boundaries, compatibility policy, and
> acceptance criteria; AI agents produced and revised a substantial portion of the implementation,
> tests, examples, and documentation. I reviewed the behavior through rendered artifacts,
> regression tests, command-line exports, and repeated design corrections. The repository includes
> a detailed provenance statement rather than presenting the work as unaided hand coding.

LogoSC is a useful demonstration of AI-assisted engineering precisely because OpenSCAD is a
peculiar and demanding target language. Its immutable values, recursion-heavy functional style,
module/function split, nested list records, preview-versus-render behavior, geometric robustness
issues, and limited conventional debugging facilities make large designs easy to get subtly
wrong. AI helped maintain context across a surprisingly broad implementation, generate repetitive
tests and documentation, explore alternatives quickly, and revise interconnected files together.

Do not claim that AI made correctness automatic. LogoSC also demonstrates the necessary limits:

- generated geometry still needed visual and mesh inspection;
- plausible code sometimes implemented the wrong geometric idea;
- user feedback repeatedly corrected scale, taper, connectivity, and API presentation;
- deterministic tests were essential because confident text is not verification; and
- human decisions defined what belonged in Core and what should remain an optional companion.

The strongest claim is not "AI wrote complex OpenSCAD, therefore it is correct." It is:

> With explicit architecture, persistent project context, tight human feedback, and executable
> verification, AI can help build and maintain OpenSCAD systems substantially larger and more
> disciplined than one-off generated models.

That is an interesting engineering result even for community members who remain skeptical of AI.

## Draft primary introduction

**Subject:** LogoSC: I wanted to make a screw and accidentally built a turtle-geometry language

> I started with a modest OpenSCAD ambition: make a screw. This escalated.
>
> Somewhere between describing a thread profile, wanting reusable 2D outlines, and discovering
> how much ceremony can hide inside an innocent-looking list, I ended up building LogoSC: a small
> Logo-inspired turtle geometry layer for OpenSCAD.
>
> LogoSC evaluates command lists such as `MOVE`, `TURN`, `ARC`, `RUN`, `REPEAT`, `HOLE`, and affine
> transforms into reusable 2D polygonal regions. Those regions can be extruded, subtracted,
> unioned, and positioned with ordinary OpenSCAD. It is deliberately not a complete Logo language
> and not a replacement for native OpenSCAD 3D modeling.
>
> The project grew beyond the original screw-shaped rabbit hole. Core now has path and region
> evaluation, holes, reusable relative command lists, debug rendering, validation, tests, and
> documentation. Optional companions exercise the approach with printable fasteners, knots and
> Celtic structures, and L-systems. The repository includes runnable galleries and command-line
> acceptance workflows rather than only screenshots.
>
> The other unusual part is how it was built: LogoSC is heavily AI-assisted. I supplied the goals,
> API and compatibility decisions, acceptance criteria, and a great deal of iterative correction;
> OpenAI tools produced and revised a substantial amount of code, testing, and documentation. I am
> disclosing that explicitly because the project is also an experiment in whether AI can manage a
> nontrivial OpenSCAD codebase despite the language's distinctive constraints—immutable values,
> recursive data processing, module/function boundaries, nested records, and geometry that may
> look plausible in preview while still being wrong for rendering or printing.
>
> My conclusion is not that AI eliminates engineering. It did make this scope practical, but the
> useful results came from persistent specifications, regression tests, exported meshes, visual
> inspection, and repeated human feedback. Some of the most convincing-looking intermediate
> answers were simply the wrong geometry.
>
> Repository: https://github.com/jbrad8254/LogoSC
>
> I would appreciate technical feedback from experienced OpenSCAD users, especially on whether the
> public API feels idiomatic, whether the Core/companion boundary makes sense, and what would need
> to change before this should be described as a generally useful OpenSCAD library. If anyone is
> willing to try the quick start or run the acceptance suite on another platform, that would be
> particularly valuable.

Before posting, replace general statements about tests and compatibility with the fresh release
candidate's exact evidence. Add the release tag and two or three direct documentation links.

## Shorter announcement

This version is suitable for `r/openscad` after the mailing-list post exists:

> I wanted to make a screw in OpenSCAD and accidentally built a turtle-geometry language.
>
> LogoSC is a Logo-inspired 2D geometry DSL written in OpenSCAD. It turns command lists into filled
> regions that work with normal extrusion and booleans, with optional validation, knots, fasteners,
> and L-system companions.
>
> It is also heavily AI-assisted, with human-directed API design and a lot of regression, export,
> and mesh verification. For me, the interesting result is that AI could help sustain a fairly
> complex OpenSCAD codebase despite the language's unusual constraints—not that generated code can
> be trusted without tests.
>
> Project and examples: https://github.com/jbrad8254/LogoSC
>
> Technical discussion: [add mailing-list thread URL]

Attach one gallery image. Do not attach every cover, suite image, and printable example.

## Possible Libraries-page request

Send this only after the first discussion and a stable release:

> Thank you for the feedback on LogoSC. The API and documentation are now tagged at [version], and
> the current acceptance runs pass on [OpenSCAD version/platforms]. Would LogoSC be an appropriate
> candidate for the official OpenSCAD Libraries page?
>
> Proposed summary: "LogoSC is a MIT-licensed Logo-inspired turtle geometry layer that evaluates
> compact command lists into reusable 2D polygonal regions for native OpenSCAD composition. It
> includes debug/validation tools, examples, tests, and optional knot, fastener, and L-system
> companions."
>
> Library: https://github.com/jbrad8254/LogoSC
> Documentation: [tagged documentation URL]
> License: MIT
>
> I am happy to follow the maintainers' preferred category, wording, image format, and pull-request
> process.

If maintainers invite a website change, edit the
[OpenSCAD website repository](https://github.com/openscad/openscad.github.com) narrowly and match
the structure already used in `libraries.html`. Do not mix unrelated website cleanup into the
listing pull request.

## Questions to ask the community

Specific questions are more likely to produce useful review than "What do you think?"

- Does the command-list API feel reasonably idiomatic for OpenSCAD, or does it fight the language?
- Is the strict boundary—LogoSC generates 2D regions; native OpenSCAD owns 3D—a useful one?
- Are `use`/`include`, filenames, installation instructions, and examples clear on Linux, macOS,
  and Windows?
- Which stable API names or record layouts would experienced library authors change before wider
  adoption?
- Are the debug and validation layers useful, or too elaborate for the problem?
- Do the tests and mesh evidence answer the right reliability questions?
- Which OpenSCAD release should be the minimum supported version?
- Does the AI provenance disclosure provide enough information to evaluate trust and maintenance?

Limit the first post to three or four questions. Keep the rest available for follow-up.

## Handling responses

Expect discussion about scope, performance, naming, whether command lists are readable, existing
libraries, and the AI contribution.

- Thank reviewers who identify overlap with BOSL2, dotSCAD, Functional OpenSCAD, or another
  library. Explain LogoSC's narrower turtle-region model before claiming differentiation.
- Treat a reproducible failing model as an engineering report, even if the surrounding comment is
  blunt.
- If somebody dislikes AI-generated code categorically, acknowledge the concern and point to the
  provenance, tests, and review process. Do not demand that the thread become an AI debate.
- Separate factual corrections from stylistic preferences and record accepted changes in the
  normal changelog/notebook workflow.
- Avoid promising API changes in real time. Restate the issue, test it, and answer with evidence.
- Credit community members when their reports materially improve the project.

## Final checklist

Before the primary post:

- [ ] Knot work and agreed release scope are complete.
- [ ] Release tag and release notes exist.
- [ ] Root README and quick start work from a clean clone.
- [ ] Minimum OpenSCAD version is stated and verified.
- [ ] Complete acceptance wall passes from the tagged commit.
- [ ] Public gallery images were regenerated from the tagged commit.
- [ ] Representative STLs are connected/manifold where manufacturability is claimed.
- [ ] `LICENSE`, contribution guidance, and AI provenance are easy to find.
- [ ] Known limitations are explicit.
- [ ] Mailing-list subscription is active before the intended post date.
- [ ] Announcement links target the tag where stability matters.
- [ ] No unreleased storefront or distribution claims leaked into the post.
- [ ] The author is available to answer replies for several days.

After the primary post:

- [ ] Archive the thread URL in this document or the release notebook.
- [ ] Triage feedback into bugs, documentation improvements, design questions, and future ideas.
- [ ] Publish corrections before requesting official library listing.
- [ ] Post the shorter visual announcement with a link to the technical discussion.
- [ ] Ask maintainers about the Libraries page only after the project is stable enough to maintain.

## Current community references

These links were verified on August 4, 2026. Community infrastructure can change, so recheck them
before release:

- [Official OpenSCAD community page](https://openscad.org/community.html)
- [OpenSCAD mailing-list information](https://lists.openscad.org/list/discuss.lists.openscad.org)
- [OpenSCAD mailing-list archive](https://lists.openscad.org/empathy/list/discuss.lists.openscad.org)
- [`#openscad` Libera.Chat web client](https://web.libera.chat/#openscad)
- [OpenSCAD subreddit](https://www.reddit.com/r/openscad/)
- [Official OpenSCAD Libraries page](https://openscad.org/libraries.html)
- [OpenSCAD website source repository](https://github.com/openscad/openscad.github.com)
- [OpenSCAD library-location documentation](https://files.openscad.org/documentation/manual/Libraries.html)

The mailing-list information page warns that its web archive is not recommended for composing new
threads and may reformat `.scad` code. Subscribe and send normal plain-text email instead. The
official community page notes that web posting may require a separate account registered with the
same subscribed email address.

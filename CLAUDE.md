# space-follow-kit

`SpaceFollowKit` — a Swift package that makes macOS subwindows follow Spaces with correct z-order and no swipe-time "always on top" glitch (the practical alternative to `canJoinAllSpaces`). Ships with a demo site in `site/`, served by a Cloudflare Worker. See [README.md](./README.md) for the package API and integration modes.

Extracted 2026-07-02 from the `socials` monorepo, where it lived as an untracked nested repo. `apple/SubwindowSpacesKit` in `socials` remains the in-app copy used directly by Obi's macOS target — keep the two in sync manually if the core behavior changes in either place.

## Linear tracking (non-negotiable)

Every agent, every session. Linear workspace: **team "Off-brand"**, **project "space-follow-kit"** (https://linear.app/off-brand-studio/project/space-follow-kit-53f7e7453d2c). Project type: `Tool`. Structure: 3 milestones — **Core kit** (the Swift package), **Demo site** (the Cloudflare Worker site), **Launch readiness** (SPM tag, real domain, license, launch/exit plan). Issue labels are namespaced under the `space-follow-kit` label group: `package` / `site`.

- **Search before creating.** `list_issues` (or `list_documents`/`list_projects`) for an existing match before filing anything new — never create a duplicate issue for work already tracked. If you find a stale/duplicate issue, mark it `Duplicate` (don't just ignore it).
- **Non-trivial work gets an issue.** A real feature, fix, decision, or roadmap item — not a one-line tweak — gets a Linear issue in **space-follow-kit**, filed as soon as the work is identified (before or at the start of work, not after). Trivial edits (typo fixes, config tweaks, comment-only changes) don't need one.
- **Every issue gets a milestone.** Attach it to **Core kit**, **Demo site**, or **Launch readiness**. An issue with no milestone is mis-filed — fix it, don't leave it orphaned.
- **Lifecycle is real, not decorative.** `Backlog` → `In Progress` the moment you start → `Done` only once it's actually shipped (merged, and — for anything visible on the demo site — verified running). Never jump straight to `Done`; never leave something you're actively building sitting in `Backlog`. If you start something and can't finish the session, leave it `In Progress` with a comment on what's left.
- **Label by area.** `package` for `Sources/SpaceFollowKit`, `site` for `site/`/`src/`.
- **Wire real dependencies.** `OFF-106` (Launch & exit plan) is blocked by `OFF-103`/`OFF-104`/`OFF-105` (SPM tag, real domain, license) — keep dependency chains like this current as new launch-readiness work gets filed.
- **Close the loop before ending a session.** If you did Linear-tracked work this session, update the issue (state change and/or a short comment on what landed) before you finish.
- **Status updates at real milestones.** When a milestone completes (or health materially changes — newly blocked/at-risk), post a `save_status_update` (type `project`, health `onTrack`/`atRisk`/`offTrack`) on **space-follow-kit** summarizing what shipped and what's next. Don't post one for routine incremental work.
- **New gaps get filed, not just noted.** If work surfaces a new readiness item or open question, file it as a real issue under **Launch readiness** rather than leaving it as prose somewhere.
- **GitHub linking is already wired** — issue branch names follow Linear's convention (`ty/off-N-slug`); use it so PRs/commits auto-link.

## Dev

```bash
# Package: open Package.swift in Xcode, or `swift build`
cd site && npm install && npm run preview   # local demo site preview (wrangler dev)
npm run deploy                              # deploy demo site
```

---
name: mod-builder
description: |
  Designs, builds and verifies a Claude Code mod (a plugin with a function-hooks module: band above
  the prompt, pane, spinner, status line, tool guard, slash command) that looks native in the
  terminal and the desktop Code tab. Triggers on: "/mod-builder", "build a mod", "make a Claude
  Code mod", "mod that shows X above the prompt", "fix how my mod looks". NOT the hooks API itself
  (load the built-in plugin-authoring skill, which this one does), settings hooks, or skills.
argument-hint: "[what the mod should do]"
---

# Build a Claude Code mod

## Purpose
Mods are easy to make work and hard to make look like they belong. Ugly mods repeat the same mistakes: painted boxes, every number coloured, an SVG rebuilt every frame, the mod's name on screen, triggers that fire too often. This skill carries what Anthropic's own mods and the best community ones do instead, so the first version looks native.

Grounded in a scan of 445 mod modules (224 that draw UI) from [awesome-claude-code-mods](https://github.com/karanb192/awesome-claude-code-mods) plus Anthropic's first-party mods, October 2026.

Needs Claude Code 2.1.287 or later (mods on). Optional: Chrome or Chromium (`scripts/svg-check.sh`), `ffmpeg` (frames from screen recordings), `tmux` (driving a terminal session).

## Defaults
Each was a correction in a real build. Build to these without asking; depart only when the user asks, and say so.
- **Scoped.** Decide which sessions it shows in (one repo, by `package.json` name or git remote, or everywhere), which data (only what *this* session started or asked about) and which surfaces (terminal, desktop; headless draws nothing). Out of scope draws nothing, not an empty state.
- **Placement fits the job; never displace the engine.** A glance under the prompt, an always-on bar above it, or detail above it on request ([design.md](references/design.md#placement)). Whatever opens grows upward without pushing the transcript.
- **Nothing moves.** Fix the band's shape before data lands: columns sized for their longest possible value, fixed-length labels, loading rows in the loaded rows' cells, a batch landing together, no state write when nothing changed.
- **No toasts.** A change shows in the row. Add a toast only for one event the user names.
- **Detect, don't act.** Read context deterministically (edited files, dev server, cwd) to offer or prefill; run only on an explicit trigger.
- **The source's vocabulary.** Mirroring a product (CI, a scoring tool, a queue)? Use its exact colours, glyphs, state names and finest state. A coarse proxy gets sent back.
- **Quiet text.** Errors grey, links in text colour, short units (`6d`, `4m`), no filler words, no mod name.
- **Reuse an existing sign-in** (a CLI's saved token, `gh`); never ask for an API key.

## Routing
| Need | Go to |
|---|---|
| Event names, `$` methods, element props, types | Load the built-in **`plugin-authoring`** skill first, every time. It starts the hot-reload watch and names the folder to write to. |
| Colour, type, spacing, layout, motion | [references/design.md](references/design.md) |
| Recipes: band, table, ring, animated SVG, Client, Raster, triggers, page detection, model fork | [references/patterns.md](references/patterns.md) |
| It renders wrong, blinks, is white, is blocked, or tests won't run | [references/gotchas.md](references/gotchas.md) |
| Which existing mod to read first | [references/exemplars.md](references/exemplars.md) |

## Procedure
1. **Pin the job, trigger and scope in one sentence.** What the user sees, what makes it appear, where. It appears only with something to say. Confirm before building any auto-trigger.
2. **Load `plugin-authoring`.** Check each prop against its `types/claude-code.d.ts` before using it. Never guess an API shape.
3. **Read one exemplar** of the same shape ([exemplars.md](references/exemplars.md)), cloned to a scratch dir. Copy idioms, not code.
4. **Design before code.** Copy [assets/mock-window.html](assets/mock-window.html) to a scratch folder and serve it: a dark desktop window with the three slots a mod draws in and bookmarkable state presets. Replace the placeholders, add a preset per state, send the user the `http://localhost` link. Every state shares one layout. Design the terminal version too: more compact, same information.
5. **Build** in the folder `plugin-authoring` names, or a repo folder loaded with `--plugin-dir`. One module; state in `$.state` with a `types/index.d.ts` contract; anything that outlives the session in `$.store` or a file.
6. **Verify, and say which checks ran:**
   - `claude plugin validate <dir>`.
   - `claude plugin test <dir>`: one test per visible state (hidden, collapsed, expanded, running, error) on `terminal` and `desktop`, plus a regression test per reported bug.
   - Render every SVG with `scripts/svg-check.sh` and look at the PNG. Tests prove the tree validates, not that it looks right.
   - Never claim the desktop look is right without the user's screenshot or your own render. For a screen recording, pull frames (`ffmpeg -i rec.mp4 -vf fps=10 f%04d.png`) and check each transition for jumps and flashes.
   - After edits, `/reload-plugins`; desktop may need a new session.
7. **Ship.** Repo with `.claude-plugin/marketplace.json`; install with `/plugin marketplace add <owner/repo>` then `/plugin install <name>@<marketplace>`. A short README: what it does, triggers, commands, known issues. Resolve machine paths from `PATH`.

## Key principles
- **Native beats clever.** Theme keys and `dimColor`/`bold`, no painted backgrounds, other mods' content (`await next(e)`) kept. If it looks injected, it is wrong.
- **Colour lives in one place per row** (a ring, a pill, a dot); values stay default text.
- **Animate inside the drawing, never by redrawing.** A self-animating SVG with a stable source, or a `Client` with its own clock.
- **Zero tokens by default.** Deterministic signals before `$.model`; when a model call earns its place, `$.model.fork` and clean the output.
- **The user's screenshot is the test that matters.** "Looks off" is a failing test: find the cause, add a test.

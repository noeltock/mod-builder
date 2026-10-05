# mod-builder

Getting a Claude Code mod to work takes an afternoon. Getting it to look like it shipped with Claude Code is the hard bit, and most don't (painted cards, every number in its own colour, the mod's name shouting at you from above the prompt). This is the skill I wish I'd had for my first one.

![Every place a mod can draw in Claude Code, numbered and named](docs/anatomy.png)

That's every place a mod can draw, with the names you'll actually type in code. Half the battle is picking the right one: a count beside the model picker is a glance, a band above the prompt is a status bar, a pane is a whole dashboard. The skill makes that call with you before anything gets built.

When I went through the awesome-claude-code-mods list in early October there were 445 mods, 224 of which draw something. I read Anthropic's own too, wrote down what the good ones do differently, and turned every regression I hit building mine into a rule or a test. There were quite a few.

## What it does
- **Pins the job first:** what you see, what makes it appear, and which sessions it belongs in. Out of scope, it draws nothing at all.
- **Designs before code:** mocks the mod up in a fake Claude desktop window, every state (hidden, collapsed, pinned, expanded, loading, offline) as a preset you click through on localhost.
- **Builds it** as a plugin with one hooks module, after reading an existing mod of the same shape.
- **Tests every state** in the terminal and the desktop app, renders any SVG on dark and light, and won't call the desktop look done without a screenshot.
- **Ships it** with a short README and an install that works.

## What it builds to
- Text in the app's own theme colours: bold for the value, dim for everything around it. No painted backgrounds, no mod name on screen.
- Nothing jumps when data lands. Columns are sized for their longest value, and loading rows sit in the same cells as loaded ones.
- No toasts by default, a change shows in the row.
- It detects, it doesn't act. It reads context to offer something and only runs when you ask.
- Zero model tokens, unless a model call actually earns its place.

## Install
```
git clone https://github.com/noeltock/mod-builder.git
cp -r mod-builder/skills/mod-builder ~/.claude/skills/
```
Needs Claude Code 2.1.287 or later. Optional: Chrome or Chromium (the SVG check), `ffmpeg` (pulling frames from a screen recording) and `tmux` (driving a real terminal session).

## Use
Ask for a mod in plain words, or call it directly:
```
/mod-builder a band above the prompt with my open PRs
/mod-builder show my deploy status beside the model picker
/mod-builder fix how my mod looks on desktop
```

## What's in it
- `SKILL.md`: the defaults and the build loop
- `references/design.md`: colour, type, layout and motion
- `references/patterns.md`: recipes for bands, tables, rings, animated SVG, panes and triggers
- `references/gotchas.md`: why it's white, why it blinks, why the band vanished
- `references/exemplars.md`: which existing mods are worth reading first
- `assets/mock-window.html`: the design mock
- `scripts/svg-check.sh`: renders an SVG the way the desktop app does

Mods are days old and the API is still moving, so some of this will age badly. We'll see. PRs welcome, MIT licensed.

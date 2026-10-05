# Designing a mod that looks native

Counts below are out of 224 UI-drawing mods scanned in October 2026, alongside Anthropic's first-party mods.

## What native looks like
Anthropic's own (`diff`, `next-steps`, Token Weather, Blast Radius, Replay Theater) share one register:
- **Text is the app's.** No custom fonts (Text has no font or size prop). `bold` for the thing (a file name, a value), `dimColor` for everything around it (labels, asides, ages, hints). `dimColor` appears in 191/224 UI mods; it is the main tool.
- **Colour comes from the theme**, by key: `success`, `warning`, `error`, `inactive`, `permission`, `claude`, `subtle`, `suggestion`, `text`. Raw hex in Text is how mods end up looking pasted in (60/224 do it; none of the first-party ones do).
- **No painted backgrounds or borders.** The band and pane are already containers. A `Box backgroundColor` reads as a box inside a box (47/224 do it; the polished ones don't).
- **Other mods first.** `const below = await next(e)` and draw it (first-party puts it above their own content). 204/224 pass `next(e)` through in render; a band that drops it erases other mods.
- **Quiet controls.** `Button plain` (often `dimColor`), with `hotkey` digits for choices ("1/2/3, 0 dismiss" in next-steps). The row's name is the link; no separate "Open" column.
- **No product name on screen.** Not the mod's own name, not "Scores are…". Column headers or nothing.
- **No toasts.** Changes show in the row: a mark changes colour, a count changes, "as of 14:02" goes dim.
- **Appear only when there is something to say.** next-steps hides while Claude works and when it has nothing; a survey (`e.props.hasSurvey`) always wins the band.

## Placement
Choose per mod; several can combine (a glance below that opens detail above).
- **Under the prompt (`SessionMode`):** a glance. A few marks and a count in microcopy (`● ● ○ 5 need you`), drawn after `await next(e)` so the model/effort controls keep their place. The count can be the toggle on desktop; the terminal footer isn't clickable, so pair it with a slash command.
- **Status bar above the prompt (`AbovePrompt`, always on):** one compact row of the numbers that matter while working in that context. Fine to leave up permanently when it's scoped to the right sessions and stays one row.
- **Detail above the prompt (`AbovePrompt`, on request):** a table or list opened by a toggle or command, growing upward; the transcript must not jump.
- **`Pane`:** only when the content needs scrolling, inputs or more than a band's rows.
- **Avoid:** a painted card with its own background, and anything that hides or replaces the engine's own controls.

## No reflow
Every jump is the layout changing under the user: a pill widening with its label, columns resizing as rows arrive, a full redraw when one job finishes.
- Size each column for its largest *possible* value (longest label in the set, widest number, clipped title), known before the first row arrives; never from the data on screen.
- Labels in a changing slot share one length: pick 4-5 character words (`Boot Load Scan Calc Done`) so the pill never resizes.
- Loading rows use the loaded row's cells (dashes or a dim placeholder in the same width).
- A batch of results lands together at its end, after the bar reaches 100% and a beat's pause, not one redraw per item.
- Compare before writing state (`JSON.stringify(next) !== JSON.stringify(prev)`): an unchanged poll must not redraw.
- A failed refresh keeps the last rows, dimmed with their age, rather than clearing to an error and back.

## Text details
- Errors and failures are grey (`dimColor`), never red. Red is for a state the source itself calls bad.
- Links stay in the text colour (underlined), not link blue.
- Short units: `6d ago` → `6d`, `this week` → `wk`. Drop a qualifier once it's implied (show `13 in 7d` once, then bare numbers).
- Numbers right-aligned, groups equidistant.

## Layout
- **Band row:** `Box flexDirection="row" gap={2} alignItems="center"`, content, `<Box flexGrow={1} />`, then the quiet control on the right.
- **Metrics (desktop):** an icon or ring at about twice the text height (36-44px; the icon grows because text can't), then a column of dim label over bold value (wavy-usage). Spread with `gap={2..3}`, not `space-between` over the whole width.
- **Tables:** fixed widths for every numeric column, `columnGap={2}`, right-aligned numbers (`justifyContent="flex-end"`), the name column `flexGrow={1}` with `wrap="truncate-end"` (or `truncate-start` for paths, as diff does), `rowGap={1}` between rows, padding around the block. Every row type (running, queued, done, failed) uses the same columns, so they align.
- **Truncation, not overflow.** Cut from the side that loses least: paths from the start, sentences from the end.
- **Width:** size to `e.props.bodyColumns` (the band's real width; narrower when a pane is docked). Drop columns from the right as it shrinks; don't wrap rows.

## Colour inside drawings (Svg)
An Svg is an isolated image with no theme variables. Use mid tones that read on light and dark (wavy-usage: calm `#1D9E75`, warn `#BA7517`, hot `#E24B4A`, track `#888780` at 0.16-0.3 opacity). A product colour is fine when the mod represents that product (its brand green, say), but only in the drawing, never in the Text.

## Motion
- **One moving thing.** A pill gliding, a ring filling, a dither shimmering. Never redraw the whole row to animate.
- **Smooth means the renderer animates**, not you: SMIL/CSS inside an `isInteractive` Svg, or a `Client` module with its own `surface.every` clock. Hook-driven frames (`$.clock.every` plus `invalidate`) step visibly, and on the desktop any band redraw reloads every animated Svg in it.
- **Progress honesty:** estimate from history (median of recent durations), creep to about 95%, snap to done when the real result lands.
- **Respect the shape of states:** queued (dim text in the bar's column) → running (the bar) → done (the result row in the same place) → failed (dim `✕ short cause`, never red text; full message in a log).

## Terminal vs desktop
- Terminal draws whole character cells: no rounded corners, no sub-cell detail except through glyphs (quadrant blocks `▘▝▀▖▌▞▛▗▚▐▜▄▙▟█`, braille, `█░` meters). `Raster` for grids (repaint with `$.ui.blit`), background `0x01000000` (the terminal's own) so it never paints a box.
- Desktop draws real layout plus `Svg` (and `Client`). The polished look lives here; design it first when the user works in the app, then make the terminal a faithful text version.
- Elements per surface: terminal has `Raster`, `Image`, `Client`; desktop has `Svg`, `Client`; vscode and mobile have `Svg` but no `Client`. Branch on `e.surface`.

## Self-check before showing the user
- Any hex text, painted background, mod name or explanatory sentence? Remove.
- Do loading and loaded rows share columns, and does anything shift when data lands?
- Is colour in exactly one element per row?
- Does it vanish when it has nothing to say, and outside its scope?
- Did you render the SVG and look at it on dark?

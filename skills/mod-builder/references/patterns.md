# Recipes

Each is a working idiom from a shipped mod. Check every prop against `plugin-authoring`'s types before relying on it.

## Band that appears only with something to say (next-steps)
```tsx
on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
  const below = await next(e).catch(() => null)      // other mods; .catch: tests have nothing beneath
  if (e.props.hasSurvey || e.props.isWorking || view.kind === 'hidden') return below
  const { Box, Text, Button } = $.ui.resolve(e)
  return (
    <Box flexDirection="column">
      {below}
      <Box marginTop={1} />
      <Text dimColor>next:</Text>
      {items.map((it, i) => (
        <Box key={`s${i}`} marginLeft={2}>
          <Button hotkey={String(i + 1)} plain label={it.label} onPress={() => choose(it)} />
        </Box>
      ))}
    </Box>
  )
})
```
Keep a small view state machine (`hidden | loading | offer`) and `$.ui.invalidate('ui.render')` when it changes. Drop stale async results by checking the `turnId` you started with.

## Aligned table where running rows become result rows
Build rows as data, then draw them with one function so every state shares columns:
```tsx
type Row = { key: string; page: RenderElement; middle: RenderElement; ageText: string }
const draw = (r: Row, action: RenderElement | null, key = r.key) => (
  <Box key={key} columnGap={2} alignItems="center">
    {r.page}{r.middle}{cell(AGE, r.ageText)}{cell(ACT, action ?? <Text> </Text>)}
  </Box>
)
// running: middle = <Box width={span}>{bar}</Box>; queued: <Box width={span}><Text dimColor>queued</Text></Box>
// done: score cells; failed: <Text dimColor>✕ {cause}</Text>
```
`span` = the score columns' total width, so the bar keeps one width and the SVG source stays stable. Collapsed view = `draw(rows[0], toggle)`; expanded = header row + `rows.map(draw)`. Don't reach into a built element's `props.children`: element objects aren't shaped for it.

## Metric with ring (wavy-usage)
```tsx
<Box flexDirection="row" gap={1} alignItems="center">
  <Svg source={ringSvg(pct, color, 36)} alt={`${label} ${value}`} width={36} height={36} />
  <Box flexDirection="column"><Text dimColor>{label}</Text><Text bold>{value}</Text></Box>
</Box>
```
Ring: track circle stroke `#888780` opacity 0.3, arc in the state colour with `stroke-dasharray` and `rotate(-90)`.

## Self-animating SVG (smooth motion on desktop)
- `isInteractive` on the `Svg` (otherwise it's a static image and SMIL/CSS don't run).
- Put `<style>:root{color-scheme:light dark}</style>` first in the SVG, or Chromium paints the sandboxed frame white on dark themes.
- Build the source once per phase from inputs that don't change during the phase (phase index, estimate), never from `now`. And don't redraw the band at all during the phase: on the desktop any redraw reloads the frame (blank plus restart), even when the source is identical. Countdowns and stage words go inside an SVG as scheduled SMIL text.
- Give it a fixed width from the layout, never from a label or counter.
- Motion with SMIL: `<animateTransform type="translate" from to dur fill="freeze"/>` for position, `<animate attributeName="fill">` for colour shifts, `<animate attributeName="opacity" values="1;0.35;1" repeatCount="indefinite">` across offset groups for shimmer, a `clipPath` rect whose `width` animates for reveal. Ids unique per phase (`done${pass}`).
- Under 131072 characters: merge dots into one `<path d="M x y h2v2h-2z…">` per layer.
- Desktop frames don't need hook timers; only the terminal path repaints.

## Client module (animated text on terminal and desktop)
For animation drawn with Box/Text (games, breathing band, live counters):
```tsx
// hooks/band.tsx
export default function Band(props: Props, surface: ClientSurface<State>) {
  const { Box, Text } = surface.elements
  if (surface.state === undefined) {
    surface.setState({ tick: 0 })
    surface.every(100, () => surface.setState({ tick: (surface.state?.tick ?? 0) + 1 }))
  }
  // surface.columns / surface.rows; surface.post(data) arrives in the hooks module as `ui.message`
  return <Box width={surface.columns}>…</Box>
}
// register: <Client key={`band:${runId}`} module="./band.tsx" width={…} height={rows} props={…} />
```
`module` must be a string literal. Key it per run, so it mounts once and isn't restarted by unrelated redraws. Client elements are Box/Text/Button/Input/Select/Link/Code/Markdown: no Svg or Raster. No mods API inside; talk through `surface.post` and `ui.message`.

## Terminal grid (Raster)
Pack `[codepoint, fg, bg]` triples as uint32 to base64; background `0x01000000` uses the terminal's own. Repaint in place with `$.ui.blit({ requestId, key, cells })` from a `$.clock.every` that runs only while something is moving; cancel it when idle.

## Triggers
- **Slash command (preferred):** `$.command.register({ name, description, argumentHint })` in `session.start` (and on first prompt/tool call after a hot reload), answered by `on('command.run', { command }, …)` returning `{}` or `{ text }`. Local: no prompt reaches Claude, no warning. `immediate: true` lets it run mid-turn.
- **Word trigger in a prompt:** possible, but swallowing the prompt (`{ drop }` or answering without `next`) always shows "A hook blocked your prompt". Only offer it with that trade-off stated; match only at the start of the message (`/^\s*word\b/i`), never mid-sentence.
- **Observing, not triggering:** `tool.call` (observe after `await next(e)`), `turn.complete` (`e.answer`, main loop only: `!e.agentId`), `prompt.submit` (`e.text`). Remember candidates; act on an explicit trigger.

## Finding "the page/project the user is working on" with no tokens
- Edited files → routes by convention: `src/pages/x.tsx` → `/x`, `app/x/page.tsx` → `/x` (strip `(group)`), `routes/x/+page.svelte` → `/x`; skip `_` and `[dynamic]` files.
- Paths and URLs mentioned in replies and prompts (`` `/pricing` ``, full `https://…`).
- The project's dev server: `lsof -nP -iTCP -sTCP:LISTEN -Fpn`, then `lsof -a -p <pids> -d cwd -Fpn`; the port whose process cwd is inside `$.session.cwd()`.
- Rank: edited this session, then mentioned, newest first; let a hint word narrow the pool, then fall back to matching project routes.

## Model calls that earn their keep
`$.model.fork({ prompt })` asks one tool-less question over the session's own transcript with the prompt cache (next-steps: "predict the next 3 prompts, JSON only"). Run it detached after `turn.complete`, never blocking the turn. Clean output before display: strip ANSI escapes, control, format and private-use characters (Unicode categories), refuse tag characters, cap length by code point. `$.prompt.fill` / `$.prompt.suggest` put text in the composer without submitting.

## State and persistence
`atom(ref, initial)` + `read`/`update`, declared in `types/index.d.ts` under `interface PluginState { '<mod>': {...} }`. A read during render subscribes the drawing, so writes redraw without `invalidate`. `$.state` survives hot reloads (module variables don't); `$.store` survives sessions; a JSONL file under `~/.claude/<mod>/` is for other tools.

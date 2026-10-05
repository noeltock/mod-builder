# Gotchas

Each one cost a round of screenshots or a broken session.

## Animated SVG on the desktop
| Symptom | Cause | Fix |
|---|---|---|
| Animated bar is a white box | An `isInteractive` Svg draws in a sandboxed frame; Chromium paints it white when its colour scheme differs from the app's | `<style>:root{color-scheme:light dark}</style>` first in the SVG. Reproduce with `scripts/svg-check.sh` |
| No animation at all | `isInteractive` missing, so the Svg is a static image | Add `isInteractive` |
| Animation blanks, restarts or strobes | **Any redraw of the band reloads an `isInteractive` Svg, even with a byte-identical source.** A ticking countdown, a polled status or a live label inside the SVG each trigger it | No redraws while it animates. Schedule label changes and countdowns inside the SVG with SMIL (`<animate attributeName="opacity" begin="Ns">`); put live detail in Text; redraw only at phase boundaries |
| Bar jumps back to the start though the mod requested no redraw | The desktop redraws the band itself (layout, prop changes) and the SMIL clock restarts at zero | Build timed SVGs resumed: shift each `begin` back by the elapsed time (a negative begin plays as if started in the past) |
| Resumed SVG shows two labels at once | Chrome drops a SMIL interval that ended before load, `fill="freeze"` included | Clamp a finished animation to end 10 ms after load (`begin = 0.01 - dur`) |
| A footer Svg silently doesn't draw | An empty `alt` drops it | Give every Svg a real `alt` |
| Headless screenshots show SMIL frozen at the start | `--virtual-time-budget` doesn't advance non-repeating SMIL | Capture in real time with a browser automation tool (open, wait, screenshot) |

## Layout and text
| Symptom | Cause | Fix |
|---|---|---|
| Mod looks "injected" | Painted `backgroundColor`, hex text, emoji, the mod's name as a label | Theme keys + `dimColor`/`bold`, no backgrounds, no name ([design.md](design.md)) |
| Band's top is cut off; updates look like full refreshes | A tree taller than `maxRows` scrolls inside `scroll.bodyRows`, and desktop Svg rows sit taller than text rows | Fit under `min(maxRows, scroll.bodyRows) - 1`, count an Svg row as more than one, "+N more" for the rest |
| The whole band vanishes; "Link href must be a non-empty string" | One bad `Link` (empty, non-canonical, not https; http only for localhost) makes the engine refuse the entire tree | Render a Link only when `new URL(href).href === href` and it is https or localhost; plain Text otherwise |
| Escape codes or newlines break a terminal row | Third-party text (PR titles, API fields) drawn as-is | Clean every outside string: C0, DEL and C1 controls to a space, collapse whitespace |
| A `[-]` overlaps the end of the terminal band | The engine draws its own band control top-right | `paddingRight={4}` on terminal band content |
| A `▾`/`▴` Button shows as `[-]` in the terminal | The terminal can't draw that glyph as a label | Words in the terminal (`more`/`less`), glyphs on desktop |
| A `v:[-]` hint line appears above the band | A band Button with a `hotkey` | No hotkey on band toggles |
| Labels flash faster than a few per second | Fast events (hundreds per second) mapped straight to labels | Fold fast phases into one calm label; change visible text at most a couple of times a second |
| Row duplicated or stale error rows | Showing every run | Latest run per key; hide failures older than the retry window |
| Band shows a run from another host for the same path | Matching history by path across hosts | Match exact URLs; treat paths only as candidates |
| Toast reads "mymod: mymod: …" | The engine prefixes the mod name | Don't prefix toasts |
| "A hook blocked your prompt" notice | Any swallowed prompt (`{ drop }` or answering without `next`) | Use a slash command; if a word trigger stays, give the drop a reason |

## Lifecycle
| Symptom | Cause | Fix |
|---|---|---|
| Mod doesn't load, or `claude plugin test` says hooks modules are turned off | Claude Code older than 2.1.287, or a cached rollout value | Update; run `claude -p ok` once online, then retest. Check with `claude -p ok --debug` → "hooks module <name> loaded" |
| A poller runs in `claude -p`, or draws nothing on desktop | The desktop also starts with `isInteractive: false` and attaches later | Start background work when `e.isInteractive` or on `session.attach`, behind a run-once flag (the field is `isInteractive`, not `interactive`) |
| Desktop shows old code | Desktop sessions don't hot-reload dir plugins reliably | Start a new session after edits |
| Dev-server detection picks the wrong port | Claude Code and headless browsers also listen from the project folder | Skip browser processes by command line, probe each candidate with `curl --max-time 2` for `text/html` 2xx/3xx, prefer preview/start/serve processes |
| A slash command treats a word as a URL (`https://pricing`) | Bare words parsed as hosts | Only `x.y`, `host:port` or dev hosts are URLs; words are hints |

## Tests
| Symptom | Cause | Fix |
|---|---|---|
| "no implementation for ui.render" | The hook returned `next(e)` (nothing beneath in tests) or threw | `.catch(() => null)` around `next(e)`; assert hidden states by expecting that error |
| Hook throws in collapsed view only | Reaching into an element's `props.children` | Build rows as data, draw with one function |
| Tests wrote real rows to `~/.claude/<mod>/` or ran real tools | No `mock.env` HOME and no `process.run` stub | Every test: `mock.env(on, { HOME: '/tmp/<mod>-test' })` plus a `process.run` stub |
| Desktop Svg has no `key` in tests | Desktop drops `key` on Svg | Find it by content (`findAll({ type: 'Svg' })` + source match) |
| "no implementation for tool.call" | The test kit route didn't take a plain stub | Test the logic as a pure function and say so |
| Asserting `module: './x.tsx'` gets `hooks/x.tsx` | Client module paths resolve relative to the plugin | `toContain('x.tsx')` |

## Verification habits
- Drive a real terminal: `tmux new-session -d -s t -x 170 -y 45 -c <project> "claude --session-id $(uuidgen)"`, `tmux send-keys -t t "/cmd" Enter`, `tmux capture-pane -t t -p`. Wait on the captured text, not a fixed sleep.
- After a visual change, ask for a screenshot from a **new** session.
- For a visual bug, find the mechanism (frame reload, sandbox, width source), not a cosmetic patch, then add a test that fails without the fix.

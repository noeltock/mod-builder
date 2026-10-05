# Exemplars: which mod to read before building

Picked by fit to the job, then craft (tests, theme keys, no painted backgrounds), then stars. Stars as of 2026-10-05; a mod inside a big repo inherits that repo's stars. Two low-star mods stay because they are the cleanest example of a technique nothing better-starred shows. Read from a scratch clone:
`git clone --depth 1 --filter=blob:none --sparse https://github.com/<repo>.git /tmp/x && git -C /tmp/x sparse-checkout set <path>`

## First-party (the native register; read one before any UI work)
| Mod | Repo / path | ★ | Read it for |
|---|---|---|---|
| next-steps | anthropics/claude-plugins-community `next-steps/` | 4.5k | The whole band idiom in one file: hide when idle, `below` first, dim label, plain hotkey buttons, `$.model.fork`, cleaning model text, `$.prompt.fill/suggest` |
| token-weather, blast-radius, replay-theater | anthropics/claude-code-playground `claude-code/mods/` | 107 | Band from state; holding a tool call with a Proceed/Cancel pane; recording and replaying edits; pane → band when narrow |
| diff | anthropics/claude-code `mods/diff` | 149k | Pane craft (bold name cut from the start, dim asides, flexGrow spacer, theme keys, no hex), 227 tests, files by noun |
| agents-md, sec-default, telemetry | anthropics/claude-code `mods/` | 149k | Behaviour-only mods: instructions, policy, the `engine.create` fold |

## By shape
| Shape | Mod | Repo / path | ★ · tests | Read it for |
|---|---|---|---|---|
| Animated band (Client) | mindful-claude | halluton/Mindful-Claude | 93 · 3 | Smallest complete `Client`: own frame clock, `surface.post` driving the spinner, keyed per turn |
| Games above the prompt | cc-arcade | sezaakgun/cc-arcade (also in davila7/claude-code-templates) | 41 · 6 | Client games paused on `turn.complete`, input via Client presses |
| Status lights band | promote-lights | yonatangross/orchestkit `mods/promote-lights` | 286 · 5 | CI lights above the prompt; same repo: `secrets-veil` (ToolResult masking), `lesson-cards` (ToolUse cards) |
| Agents tree pane | agent-flow | davila7/claude-code-templates `cli-tool/components/mods/ui/agent-flow` | 32k host · 1 | Subagent tree beside the transcript |
| Pane dashboard | linear-tickets, vercel-deploys | davila7/claude-code-templates `cli-tool/components/mods/integrations/` | 32k host · 1 | Small, clean list panes over an outside service (no hex, no backgrounds) |
| Multi-agent pane | claude-council | hex/claude-council | 830 · 14 | Band + pane with Input, Select, Markdown answers from several CLIs (ignore its painted backgrounds) |
| Pane with Input/Code | hope | saadshahd/moo.md `hope/` | 35 · 1 | Compact pane with Input, Code and Buttons; same repo `hunch` restyles messages with a Client + Markdown |
| Context hygiene, Raster | contextsaver, compact-adviser | AlmogBaku/ContextSaver; kunchenguid/compact-adviser `packages/claude-mod` | 25 / 196 · 109 / 3 | The deepest test suite in the ecosystem; Raster in a pane; advising `/compact` |
| Transcript rail | prompt-rail | oikon48/prompt-rail | 19 · 1 | A rail of the session's prompts with hover, across seven render components |
| Browser in a pane | terminal-browser | zenbu-labs/terminal-browser `claude-code-plugin` | 3.6k · 0 | Client + Image streaming a real browser |
| Behaviour (no UI) | fast-jev-compaction, shunt, cache-tax | tamaratran/fast-jev-compaction; pleaseai/shunt; karanb192/cache-tax | 7.4k / 224 / 40 | Compaction replacement, per-agent model routing proxy, cache keep-warm with cost preview |
| Desktop metric band (low ★, kept) | wavy-usage | BatuhanCakmakk/wavy-usage | 3 · 6 | One of only two mods that draw Svg: 36-44px rings, dim label over bold value, SMIL with byte-stable sources, terminal text fallback |
| Terminal meter band (low ★, kept) | context-view | kongyo2/context-view | 1 · 55 | Meters drawn like Claude Code's own: theme keys (`permission/warning/error`), `█░` glyphs, tiny files by noun, heavy tests |

## Ecosystem habits (224 UI mods)
Surfaces: Pane 139, AbovePrompt 96, PromptHint 14, AssistantMessage 13. Elements beyond Box/Text: Button 146, Client 37, Input 35, Raster 21, Select 15, Link 12, Svg 2. Only 14 use theme keys alone; 60 use raw hex and 47 paint backgrounds. Find newer mods in [awesome-claude-code-mods](https://github.com/karanb192/awesome-claude-code-mods).

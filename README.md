# mod-builder

A Claude Code skill for building mods that look like they shipped with Claude Code.

![Every place a mod can draw in Claude Code, numbered and named](docs/anatomy.png)

That's everywhere a mod can draw, with the names you'll use in code. The skill picks the right spot, mocks the mod up in a fake desktop window before writing any code, builds it, then tests every state in the terminal and the desktop app. The rules come from going through 445 mods plus Anthropic's own, and from every regression I hit building mine.

## Install
```
/plugin marketplace add noeltock/mod-builder
/plugin install mod-builder@mod-builder
```
Then just ask for a mod, or run `/mod-builder:build-claude-mod a band with my open PRs`. Needs Claude Code 2.1.287 or later.

Mods are only days old, so some of this will age badly. PRs welcome. MIT.

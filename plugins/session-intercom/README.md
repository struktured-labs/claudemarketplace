# session-intercom plugin

P2P messaging between independent Claude Code sessions, bundled as a Claude Code plugin.

Ships the [session-intercom](https://github.com/struktured-labs/session-intercom) MCP server plus a one-call setup slash command, an auto-activating skill, and a SessionStart hook that registers every session automatically. Inbound messages arrive between turns as `<channel>` tags via the [Channels API](https://code.claude.com/docs/en/channels-reference) — no polling, no file inbox, no team binding to repair.

## Install

```
/plugin marketplace add struktured-labs/claudemarketplace
/plugin install session-intercom@struktured-labs
```

## Launch flag (required)

session-intercom uses the Channels API, currently in research preview. Custom channels aren't on Anthropic's allowlist, so launch Claude Code with:

```bash
claude --dangerously-load-development-channels server:session-intercom
```

If `<channel>` tags never arrive when other sessions DM you, the first thing to check is whether this flag was on the launch command.

## Auto-setup (zero commands per session)

Once installed, a **SessionStart hook** registers each session for you. On every new/resumed session it injects an instruction telling Claude to run `intercom_register(name=<auto-derived-from-cwd>)`. No per-session command needed.

The hook only injects the instruction — Claude makes the actual MCP call. If the intercom MCP tools aren't available, the hook is a silent no-op.

## Manual setup (override the auto-derived name)

```
/session-intercom:intercom <your-session-name>
```

Use this when you want a name different from the auto-derived project-directory name. If you omit the name, it picks one based on your cwd.

## Use

Your own name is implicit after registration. Send a direct message:

```
intercom_send(to_name="recipient-name", body="hello from over here")
```

Broadcast to a channel:

```
intercom_broadcast(body="deploy is green")
```

See who's online:

```
intercom_list_sessions()
```

## What's included

- **MCP server** — `session-intercom` (stdio, run via `uvx` from github)
- **Slash command** — `/session-intercom:intercom` (one-call setup)
- **Skill** — `session-intercom` (auto-activates on messaging/coordination intent)
- **SessionStart hook** — `hooks/session-start.sh` (auto-registers every session; fires on startup / resume / clear)

## Requirements

- `uv` installed (for `uvx` to fetch and run the MCP server)
- Claude Code v2.1.80 or later (channels API)
- Launch with `--dangerously-load-development-channels server:session-intercom` until/unless this plugin gets allowlisted

## Upstream

Source: https://github.com/struktured-labs/session-intercom

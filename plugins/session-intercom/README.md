# session-intercom plugin

P2P messaging between independent Claude Code sessions, bundled as a Claude Code plugin.

Ships the [session-intercom](https://github.com/struktured-labs/session-intercom) MCP server plus a one-command setup slash command, an auto-activating skill, and a SessionStart hook that registers every session automatically — install and go.

## Install

```
/plugin marketplace add struktured-labs/claudemarketplace
/plugin install session-intercom@struktured-labs
```

## Auto-setup (zero commands)

Once installed, a **SessionStart hook** registers each session for you. On every
new/resumed session it injects an instruction telling Claude to run `TeamCreate`
+ `intercom_register` with a name derived from your project directory, and to
self-heal if native delivery is stale. No per-session command needed.

The hook only injects the instruction — Claude makes the actual calls, because
`TeamCreate` binds the CLI's in-process inbox poller to the live conversation
and can't be done from a shell hook. If the intercom MCP tools aren't available,
the hook is a silent no-op.

## Manual setup (override the auto-derived name)

```
/session-intercom:intercom <your-session-name>
```

This wraps `TeamCreate` + `intercom_register` into one step. Use it when you want
a name different from the auto-derived project-directory name. If you omit the
name, it picks one based on your cwd.

## Use

Your own name is implicit after `/intercom`. Send a direct message:

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
- **Slash command** — `/session-intercom:intercom` (one-command setup)
- **Skill** — `session-intercom` (auto-activates on messaging/coordination intent)
- **SessionStart hook** — `hooks/session-start.sh` (auto-registers every session; fires on startup / resume / clear)

## Requirements

- `uv` installed (for `uvx` to fetch and run the MCP server)
- Claude Code with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (for native inbox delivery)

## Upstream

Source: https://github.com/struktured-labs/session-intercom

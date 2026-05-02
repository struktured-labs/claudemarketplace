# session-intercom plugin

P2P messaging between independent Claude Code sessions, bundled as a Claude Code plugin.

Ships the [session-intercom](https://github.com/struktured-labs/session-intercom) MCP server plus a one-command setup slash command and an auto-activating skill — install and go.

## Install

```
/plugin marketplace add struktured-labs/claudemarketplace
/plugin install session-intercom@struktured-labs
```

## Setup (one command per session)

```
/session-intercom:intercom <your-session-name>
```

That's it. This wraps `TeamCreate` + `intercom_register` into one step, enabling native zero-polling inbox delivery. Messages from other sessions now arrive automatically between turns, like teammate notifications.

If you omit the name, the command will pick one based on your cwd.

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

## Requirements

- `uv` installed (for `uvx` to fetch and run the MCP server)
- Claude Code with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (for native inbox delivery)

## Upstream

Source: https://github.com/struktured-labs/session-intercom

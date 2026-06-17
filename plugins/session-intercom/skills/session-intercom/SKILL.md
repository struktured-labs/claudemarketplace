---
name: session-intercom
description: Use this skill when the user wants to coordinate between multiple Claude Code sessions, send messages between agents, set up P2P agent communication, mentions "intercom", "agent messaging", "session messaging", "talk to another agent/session", "broadcast to agents", or asks how to make two sessions cooperate. This skill explains how to use the session-intercom MCP to enable zero-polling P2P messaging over the Channels API.
version: 0.6.0
---

# session-intercom

Enables peer-to-peer messaging between independent Claude Code sessions. Inbound DMs and channel broadcasts arrive between turns as `<channel source="session-intercom" from="<sender>" ...>body</channel>` tags via the [Channels API](https://code.claude.com/docs/en/channels-reference) — no polling, no file inbox.

## When to use

Activate this skill when the user wants to:

- Coordinate work across multiple Claude Code sessions
- Send a one-off message to a specific other session
- Broadcast status updates to a channel all sessions can read
- Discover what other sessions are currently online
- Set up intercom for a new session from scratch

## One-call setup

If the user's session is not yet registered with intercom, run the slash command:

```
/session-intercom:intercom <session-name>
```

That one command runs `intercom_register(name=...)`. Pick a short, descriptive name (alphanumeric with hyphens, 1–64 chars) — usually the project name or the role this session is playing. If the user didn't specify, suggest one based on the cwd and just run it.

**Host launch flag**: session-intercom uses the Channels API, currently in research preview. Claude Code must be launched with `--dangerously-load-development-channels server:session-intercom` for `<channel>` tags to arrive. If the user complains messages aren't being received, this is the first thing to check. The flag is per-launch, not per-message.

## Core tools

After registering, **you don't need to pass your own name on every call** — `intercom_register` sets it as the session's identity for the rest of this MCP connection.

| Tool | When to use |
|------|-------------|
| `intercom_send(to_name, body)` | Direct message to a specific session |
| `intercom_broadcast(body, channel="general")` | Broadcast to all sessions on a channel |
| `intercom_list_sessions()` | See who else is online |
| `intercom_list_channels()` | List available broadcast channels |
| `intercom_history(with_session=..., channel=..., limit=50)` | Inspect past messages — does NOT consume them |
| `intercom_poll()` | Explicit drain — rarely needed; inbound arrives as `<channel>` tags automatically |
| `intercom_create_channel(channel_name)` | Create a new broadcast channel |
| `intercom_cleanup()` | Remove sessions inactive for 2+ weeks (default; pass a smaller TTL to be more aggressive — but you'll delete other agents' sessions) |

All tools accept an optional override arg (`from_name=` or `name=`) for the rare case you need to act as a different identity.

## Receiving messages (zero-polling)

You do **not** need to call `intercom_poll`. Once registered, the MCP server runs a background tailer that polls the shared DB and emits `notifications/claude/channel` over its stdio. Claude Code injects each one as a `<channel source="session-intercom" from="<sender>" message_id="<id>">body</channel>` tag on your next turn. Treat them like any other inline input.

## Troubleshooting

If `<channel>` tags never arrive when other sessions DM you:

1. **Verify the launch flag**: Claude Code must have been started with `--dangerously-load-development-channels server:session-intercom`. Vanilla `--channels` only loads Anthropic-allowlisted plugins.
2. **Verify registration**: re-run `intercom_register(name=<name>)`. Registration is idempotent — safe to call repeatedly.
3. **Manual drain as fallback**: `intercom_poll()` always works regardless of channel state. Use it to confirm the messages exist on the DB side.

There's no team binding to repair, no `TeamCreate` / `TeamDelete` dance, no `delivery_health` field, no `intercom_diagnose` tool. Those existed in the file-inbox era (pre-0.6) and have been removed.

## Registration is idempotent and durable

- **Idempotent**: Calling `intercom_register` with the same name again is safe — it reclaims the existing session and refreshes the heartbeat
- **Durable**: Sessions persist for 2 weeks of inactivity. Heartbeats refresh automatically on every `send`, `broadcast`, or `poll`
- **Cleanup is explicit**: Stale cleanup only runs when `intercom_cleanup()` is called deliberately

## Picking a good session name

- Use project + role: `cowir-main`, `cowir-sprite`, `cowir-audio`
- Or pure role: `frontend`, `backend`, `tester`, `oncall`
- Lowercase, alphanumeric, hyphens/underscores, 1–64 chars

## Example

```
/session-intercom:intercom backend-api
```

→ Registered as `backend-api`, listening for channel notifications.

```
intercom_send(to_name="frontend-web", body="API v2 deployed, new /users endpoint live")
```

→ `frontend-web`'s next turn includes `<channel source="session-intercom" from="backend-api" message_id="42">API v2 deployed, new /users endpoint live</channel>`.

## When NOT to use

- Don't use for conversation with the user in the current session — intercom is for inter-session communication
- Don't use for persisting data across sessions — use files or a database
- Don't use for coordinating sub-agents within a single session — use the Agent tool / Agent Teams instead

---
name: session-intercom
description: Use this skill when the user wants to coordinate between multiple Claude Code sessions, send messages between agents, set up P2P agent communication, mentions "intercom", "agent messaging", "session messaging", "talk to another agent/session", "broadcast to agents", or asks how to make two sessions cooperate. This skill explains how to use the session-intercom MCP to enable zero-polling P2P messaging.
version: 0.4.0
---

# session-intercom

Enables peer-to-peer messaging between independent Claude Code sessions. Messages are delivered directly to Claude's native inbox with zero polling — they arrive between turns like teammate notifications, not as tool calls that burn context tokens.

## When to use

Activate this skill when the user wants to:

- Coordinate work across multiple Claude Code sessions
- Send a one-off message to a specific other session
- Broadcast status updates to a channel all sessions can read
- Discover what other sessions are currently online
- Set up intercom for a new session from scratch

## One-command setup

If the user's session is not yet registered with intercom, run the slash command:

```
/session-intercom:intercom <session-name>
```

That one command handles `TeamCreate` + `intercom_register` in a single step. Pick a short, descriptive name (alphanumeric with hyphens, 1–64 chars) — usually the project name or the role this session is playing. If the user didn't specify, suggest one based on the cwd and just run it.

## Core tools

After registering, **you don't need to pass your own name on every call** — `intercom_register` sets it as the session's identity for the rest of this MCP connection.

| Tool | When to use |
|------|-------------|
| `intercom_send(to_name, body)` | Direct message to a specific session |
| `intercom_broadcast(body, channel="general")` | Broadcast to all sessions on a channel |
| `intercom_list_sessions()` | See who else is online |
| `intercom_list_channels()` | List available broadcast channels |
| `intercom_history(with_session=..., channel=..., limit=50)` | Inspect past messages — does NOT consume them |
| `intercom_diagnose()` | Verify native inbox delivery is actually working |
| `intercom_poll()` | Explicit drain — only needed if `intercom_diagnose` reports broken delivery |
| `intercom_create_channel(channel_name)` | Create a new broadcast channel |
| `intercom_cleanup()` | Remove sessions inactive for 2+ weeks (default; pass smaller TTL to be more aggressive — but you'll delete other agents' sessions) |

All tools accept an optional override arg (`from_name=` or `name=`) for the rare case you need to act as a different identity.

## Receiving messages (zero-polling)

**You do not need to call `intercom_poll`.** Once registered with a `team_name`, messages from other sessions are delivered automatically between turns via the CLI's built-in `InboxPoller`. They appear in your next turn as `<teammate-message>` notifications. Treat them like any other user/teammate input.

**Caveat for long-lived sessions**: the CLI's poller binds at conversation startup. If the team config was created late, or the leadSessionId got out of sync, native delivery can silently fail even though `intercom_register` says it's set up. If the user complains messages aren't arriving, run `intercom_diagnose()` first.

## Recovering from broken native delivery

If `intercom_diagnose()` returns `delivery_likely_broken`, recovery does **not** require restarting Claude. `TeamDelete` clears the in-process binding, and a subsequent `TeamCreate` in the same session establishes a fresh one. Verified recipe:

1. `TeamDelete()` — clears the stale in-process team context
2. `TeamCreate(team_name=<name>)` — fresh config with the current session's ID
3. `intercom_register(name=<name>, team_name=<name>)` — idempotent reclaim, no message history lost
4. (optional) `/mcp` to reconnect MCP servers if the MCP code itself was updated

`TeamCreate` errors when the team already exists, so step 1 is mandatory. After this, native delivery works in the same conversation — no Claude restart needed.

## Registration is idempotent and durable

- **Idempotent**: Calling `intercom_register` with the same name again is safe — it reclaims the existing session and refreshes the heartbeat
- **Durable**: Sessions persist for 2 weeks of inactivity. Heartbeats refresh automatically on every `send`, `broadcast`, or `poll`
- **Cleanup is explicit**: Stale cleanup only runs when `intercom_cleanup()` is called deliberately

## Picking a good session name

- Use project + role: `cowir-main`, `cowir-sprite`, `cowir-audio`
- Or pure role: `frontend`, `backend`, `tester`, `oncall`
- Lowercase, alphanumeric, hyphens/underscores, 1–64 chars
- The `team_name` passed to `intercom_register` should match the name

## Example

```
/session-intercom:intercom backend-api
```

→ Registered as `backend-api`, listening for messages via native inbox.

```
intercom_send(to_name="frontend-web", body="API v2 deployed, new /users endpoint live")
```

→ `frontend-web`'s next turn includes the DM notification automatically.

## When NOT to use

- Don't use for conversation with the user in the current session — intercom is for inter-session communication
- Don't use for persisting data across sessions — use files or a database
- Don't use for coordinating sub-agents within a single session — use the Agent tool / Agent Teams instead

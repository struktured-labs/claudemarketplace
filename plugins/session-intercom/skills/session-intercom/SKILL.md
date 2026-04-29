---
name: session-intercom
description: Use this skill when the user wants to coordinate between multiple Claude Code sessions, send messages between agents, set up P2P agent communication, mentions "intercom", "agent messaging", "session messaging", "talk to another agent/session", "broadcast to agents", or asks how to make two sessions cooperate. This skill explains how to use the session-intercom MCP to enable zero-polling P2P messaging.
version: 0.3.2
---

# session-intercom

Enables peer-to-peer messaging between independent Claude Code sessions. Messages are delivered directly to Claude's native inbox with zero polling — they arrive between turns like teammate notifications, not as tool calls that burn context tokens.

## When to use

Activate this skill when the user wants to:

- Coordinate work across multiple Claude Code sessions (e.g. frontend session + backend session + tests session working on the same project)
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

Once registered, use these MCP tools (all namespaced `mcp__session-intercom__*`):

| Tool | When to use |
|------|-------------|
| `intercom_send(from_name, to_name, body)` | Direct message to a specific session |
| `intercom_broadcast(from_name, body, channel="general")` | Broadcast to all sessions on a channel |
| `intercom_list_sessions()` | See who else is online |
| `intercom_list_channels()` | List available broadcast channels |
| `intercom_history(name, with_session=..., channel=..., limit=50)` | Look at past messages |
| `intercom_diagnose(name)` | Verify native inbox delivery is actually working — run this if messages don't seem to be arriving |
| `intercom_poll(name)` | **Only if the user explicitly opted out of native inbox**, or as a workaround when `intercom_diagnose` reports broken delivery. Native delivery is automatic when working. |

## Receiving messages (zero-polling)

**You do not need to call `intercom_poll`.** Once registered with a `team_name`, messages from other sessions are delivered automatically between turns via the CLI's built-in `InboxPoller`, exactly like agent-team messages. They'll just appear in your next turn as `[intercom DM from xyz]` notifications. Treat them like any other user/teammate input.

**Caveat for long-lived sessions**: the CLI's poller binds at conversation startup. If the team config was created late, or your conversation has been running across many compactions and the leadSessionId no longer matches, native delivery can silently fail even though `intercom_register` says it's set up. If the user complains messages aren't arriving, run `intercom_diagnose(<name>)` first — it'll tell you whether the file inbox has unread messages stuck behind a stale binding.

## Recovering from broken native delivery

If `intercom_diagnose` returns `delivery_likely_broken`, recovery does **not** require restarting Claude. `TeamDelete` clears the in-process binding, and a subsequent `TeamCreate` in the same session establishes a fresh one. Verified recipe:

1. **`TeamDelete()`** in the broken session (no args — operates on the current session's team). Wipes `~/.claude/teams/<name>/` and `~/.claude/tasks/<name>/` and clears the stale team context from the in-process binding.
2. **`TeamCreate(team_name=<name>)`** — fresh config with the current session's ID as lead.
3. **`intercom_register(name=<name>, team_name=<name>)`** — idempotent reclaim of the existing intercom DB row, no message history lost.
4. (optional) **`/mcp`** to reconnect MCP servers if the MCP code itself was updated and the running server has stale code.

This is the same thing the `/session-intercom:intercom` slash command does, except `TeamCreate` will refuse to run on an existing team unless you `TeamDelete` first. So:

- **Fresh session, no team yet**: just run `/session-intercom:intercom <name>` — done.
- **Broken binding on existing team**: `TeamDelete()` first, then `/session-intercom:intercom <name>`.

Why use `TeamDelete` rather than `rm -rf` on the team directory: `TeamDelete` also clears the in-process team context binding, which a disk-only delete can't touch.

## Registration is idempotent and durable

- **Idempotent**: Calling `intercom_register` with the same name again is safe — it reclaims the existing session and refreshes the heartbeat. No errors, no data loss.
- **Durable**: Sessions persist for 2 weeks of inactivity. Heartbeats refresh automatically on every `intercom_send`, `intercom_broadcast`, or `intercom_poll`. There's no need to manually keep-alive.
- **Cleanup is explicit**: Stale cleanup only runs when `intercom_cleanup()` is invoked deliberately. Other agents' sessions won't be silently deleted by your operations.

## Picking a good session name

- Use project + role: `cowir-main`, `cowir-sprite`, `cowir-audio`
- Or pure role: `frontend`, `backend`, `tester`, `oncall`
- Lowercase, alphanumeric, hyphens/underscores, 1–64 chars
- The `team_name` passed to `intercom_register` should match the name (they're the same identity)

## Example: starting a session that joins intercom

```
/session-intercom:intercom backend-api
```

→ Session is now registered as `backend-api`, listening for messages via native inbox, visible to other sessions via `intercom_list_sessions`.

```
intercom_send("backend-api", "frontend-web", "API v2 deployed, new /users endpoint live")
```

→ `frontend-web`'s next turn includes the DM notification automatically.

## When NOT to use

- Don't use for conversation with the user in the current session — intercom is for inter-session communication
- Don't use for persisting data across sessions — use files or a database
- Don't use for coordinating sub-agents within a single session — use the Agent tool / Agent Teams instead

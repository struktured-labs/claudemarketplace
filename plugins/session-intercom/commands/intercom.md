---
description: Set up session-intercom for this session (TeamCreate + intercom_register in one step)
argument-hint: <session-name>
allowed-tools: [TeamCreate, TeamDelete, mcp__plugin_session-intercom_session-intercom__intercom_register, mcp__plugin_session-intercom_session-intercom__intercom_list_sessions]
---

# /intercom — one-command setup

The user wants to join the session-intercom network with session name: **$ARGUMENTS**

If no name was provided, pick a sensible one based on the current working directory (e.g. the project folder name, lowercased, alphanumeric/hyphens only, 1–64 chars) and tell the user what you chose.

## Steps to perform

1. **Create the native team** so the CLI's InboxPoller will watch this session's inbox:
   ```
   TeamCreate(team_name=<name>)
   ```
   If TeamCreate errors with "Already leading team", run `TeamDelete()` first (it operates on the current team), then retry `TeamCreate`. This is required to refresh a stale poller binding.

2. **Register with intercom** to enable native delivery and set this as the session's identity:
   ```
   intercom_register(name=<name>, team_name=<name>)
   ```
   After this, all other intercom tools default to `<name>` — no need to pass `from_name` on every call. Registration is idempotent.

3. **List other sessions** so the user knows who they can talk to:
   ```
   intercom_list_sessions()
   ```

4. **Report back** concisely:
   - The session name that was registered
   - Whether `inbox_file_ready: true` came back from register (note: this only confirms the file is set up, not that delivery is firing — recommend `intercom_diagnose()` to verify if the user later complains)
   - A short list of currently-active sessions (or "no other sessions online")
   - One-line reminder: "Send messages with `intercom_send(to_name=\"<recipient>\", body=\"...\")` — no need to repeat your own name."

Do NOT ask for confirmation before running the steps — the user already invoked `/intercom`, that IS the confirmation. Just do it and report the result.

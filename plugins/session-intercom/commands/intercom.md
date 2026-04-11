---
description: Set up session-intercom for this session (TeamCreate + intercom_register in one step)
argument-hint: <session-name>
allowed-tools: [TeamCreate, mcp__session-intercom__intercom_register, mcp__session-intercom__intercom_list_sessions]
---

# /intercom — one-command setup

The user wants to join the session-intercom network with session name: **$ARGUMENTS**

If no name was provided, pick a sensible one based on the current working directory (e.g. the project folder name, lowercased, alphanumeric/hyphens only, 1–64 chars) and tell the user what you chose.

## Steps to perform

1. **Create the native team** so the CLI's InboxPoller will watch this session's inbox:
   ```
   TeamCreate(team_name=<name>)
   ```
   If TeamCreate reports that the team already exists, that's fine — continue.

2. **Register with intercom**, passing the same name as `team_name` to enable native inbox delivery:
   ```
   mcp__session-intercom__intercom_register(name=<name>, team_name=<name>)
   ```
   Registration is idempotent — safe to call even if the session was already registered.

3. **List other sessions** so the user knows who they can talk to:
   ```
   mcp__session-intercom__intercom_list_sessions()
   ```

4. **Report back** concisely:
   - The session name that was registered
   - Whether native inbox delivery is active (the register response will include `native_inbox: true` if so)
   - A short list of other currently-active sessions (or "no other sessions online")
   - One-line reminder: "Send messages with `intercom_send(\"<name>\", \"<recipient>\", \"...\")` or broadcast with `intercom_broadcast(\"<name>\", \"...\")`."

Do NOT ask for confirmation before running the steps — the user already invoked `/intercom`, that IS the confirmation. Just do it and report the result.

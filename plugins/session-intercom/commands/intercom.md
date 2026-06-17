---
description: Register this session with the intercom network (one call, channels-mode delivery)
argument-hint: <session-name>
allowed-tools: [mcp__plugin_session-intercom_session-intercom__intercom_register, mcp__plugin_session-intercom_session-intercom__intercom_list_sessions]
---

# /intercom — one-call setup

The user wants to join the session-intercom network with session name: **$ARGUMENTS**

If no name was provided, pick a sensible one based on the current working directory (e.g. the project folder name, lowercased, alphanumeric/hyphens only, 1–64 chars) and tell the user what you chose.

## Steps to perform

1. **Register**:
   ```
   intercom_register(name=<name>)
   ```
   After this, all other intercom tools default to `<name>` — no need to pass `from_name`. Registration is idempotent.

2. **List other sessions** so the user knows who they can talk to:
   ```
   intercom_list_sessions()
   ```

3. **Report back** concisely:
   - The session name that was registered
   - A short list of currently-active sessions (or "no other sessions online")
   - One-line reminder: "Send messages with `intercom_send(to_name=\"<recipient>\", body=\"...\")` — your own name is implicit."
   - **If and only if** the user appears not to have launched Claude Code with channels enabled (no `<channel>` tags ever arrive when other sessions DM them), tell them they may need to relaunch with: `claude --dangerously-load-development-channels server:session-intercom`. Don't surface this caveat preemptively — it's noise when channels are already working.

Do NOT ask for confirmation before running the steps — the user already invoked `/intercom`, that IS the confirmation. Just do it and report the result.

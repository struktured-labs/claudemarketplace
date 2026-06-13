#!/usr/bin/env bash
#
# session-intercom — SessionStart auto-setup hook
#
# Emits a SessionStart additionalContext instruction telling Claude to register
# this session with the intercom network. The actual TeamCreate +
# intercom_register calls MUST be made by Claude itself: TeamCreate binds the
# CLI's in-process inbox poller to the current conversation, and
# intercom_register sets the default session identity inside the per-session MCP
# server process. Neither is reachable from a shell hook, so this hook only
# injects the instruction.
#
# Fires on startup / resume / clear (see hooks.json matcher). Registration is
# idempotent, so re-firing is safe.

set -euo pipefail

# Derive a stable session name from the project directory: lowercased basename,
# every char outside [a-z0-9-] folded to '-', collapsed and trimmed, capped at
# 64 chars. The result is restricted to [a-z0-9-], so it is safe to embed in the
# JSON below without escaping.
src_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
name="$(basename -- "$src_dir" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -c 'a-z0-9-' '-' \
  | sed -E 's/-+/-/g; s/^-+//; s/-+$//' \
  | cut -c1-64)"
if [ -z "$name" ]; then
  name="claude-session"
fi

# One-line additionalContext (no embedded newlines → no JSON escaping needed).
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "session-intercom auto-setup: before handling the user request, register this session with the intercom network. (1) Call TeamCreate with team_name '${name}' (an already-exists result is fine). (2) Call mcp__session-intercom__intercom_register with name '${name}' and team_name '${name}'. (3) If the register response reports delivery_health 'likely_broken', call TeamDelete, then TeamCreate with team_name '${name}', then intercom_register again. Then print one short status line (the registered name and whether native inbox delivery is active) and continue with the user's request. If the session-intercom MCP tools are not available, skip this silently."
  }
}
EOF

exit 0

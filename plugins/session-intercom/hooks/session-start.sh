#!/usr/bin/env bash
#
# session-intercom — SessionStart auto-setup hook
#
# Emits a SessionStart additionalContext instruction telling Claude to register
# this session with the intercom network. Registration is a single
# intercom_register call now that delivery runs over the Channels API — no
# TeamCreate, no team binding to repair.
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
    "additionalContext": "session-intercom auto-setup: before handling the user request, register this session with the intercom network by calling mcp__plugin_session-intercom_session-intercom__intercom_register with name '${name}'. Registration is idempotent and inbound DMs will arrive automatically between turns as <channel source=\"session-intercom\" ...> tags. Print one short status line (the registered name) and continue with the user's request. If the session-intercom MCP tools are not available, skip this silently. If <channel> tags never arrive when other sessions DM you, the host probably wasn't launched with --dangerously-load-development-channels server:session-intercom."
  }
}
EOF

exit 0

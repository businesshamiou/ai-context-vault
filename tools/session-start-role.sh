#!/usr/bin/env bash
# SessionStart hook (native, not a plugin): injects the executor role for
# CLI sessions opened in the Vault. See RULES-2026-08-23-224706, barreau 1.
# Mission 039 : cable au preflight (silence si READY, une ligne sinon).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PREFLIGHT="$SCRIPT_DIR/session-preflight.sh"

CONTEXT='role: executor\nvault root: C:/Users/hamio/Workspaces/workshops/vault\ncharter: rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md\nforbidden: git push - announce role in first message'

if [ -x "$PREFLIGHT" ]; then
  PREFLIGHT_OUT="$(bash "$PREFLIGHT" 2>/dev/null || true)"
  case "$PREFLIGHT_OUT" in
    NOT-READY*)
      CONTEXT="${CONTEXT}\nPreflight ${PREFLIGHT_OUT}, see .claude/.preflight_stamp.json"
      ;;
  esac
fi

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$CONTEXT"

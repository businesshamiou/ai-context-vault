#!/usr/bin/env bash
# SessionStart hook (native, not a plugin): injects the executor role for
# CLI sessions opened in the Vault. See RULES-2026-08-23-224706, barreau 1.
set -euo pipefail

CONTEXT='role: executor\nvault root: C:/Users/hamio/Workspaces/workshops/vault\ncharter: rules/RULES-2026-08-23-224706-role-charter-and-session-determination.md\nforbidden: git push - announce role in first message'

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$CONTEXT"

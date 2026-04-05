#!/bin/bash
# .claude/hooks/on-code-review-fail.sh
#
# code-reviewer-claude 또는 code-reviewer-codex 완료 시,
# Block 또는 Request Changes 판정이면 Slack 알림.
# SubagentStop 이벤트에 연결, matcher로 code-reviewer-claude|code-reviewer-codex 필터.

set -euo pipefail

INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // "unknown"')
OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // .stop_reason // ""')

# Block 또는 Request Changes 판정 확인
if echo "$OUTPUT" | grep -qiE 'Block|Request Changes'; then
  # 판정 추출
  if echo "$OUTPUT" | grep -qiE 'Block'; then
    VERDICT="🔴 BLOCKED"
    SEVERITY="error"
  else
    VERDICT="⚠️ Request Changes"
    SEVERITY="warning"
  fi

  # Critical 이슈 수 추출 시도
  CRITICAL_COUNT=$(echo "$OUTPUT" | grep -coiE '🔴 Critical|Critical' || echo "0")
  WARNING_COUNT=$(echo "$OUTPUT" | grep -coiE '🟡 Warning|Warning' || echo "0")

  jq -n \
    --arg agent "$AGENT_TYPE" \
    --arg verdict "$VERDICT" \
    --arg critical "$CRITICAL_COUNT" \
    --arg warning "$WARNING_COUNT" \
    --arg severity "$SEVERITY" \
    '{
      "title": ("Code Review " + $verdict),
      "message": ("*Reviewer:* `" + $agent + "`\n*Verdict:* " + $verdict + "\n\n🔴 Critical: " + $critical + "\n🟡 Warning: " + $warning + "\n\nAction required — check Claude Code for details."),
      "severity": $severity
    }' | "$CLAUDE_PROJECT_DIR/.claude/hooks/slack-notify.sh"
fi

exit 0

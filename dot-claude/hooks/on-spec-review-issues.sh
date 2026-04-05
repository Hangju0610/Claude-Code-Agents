#!/bin/bash
# .claude/hooks/on-spec-review-issues.sh
#
# spec-reviewer가 완료될 때, 결과에 수정 필요 이슈가 있으면 Slack 알림.
# SubagentStop 이벤트에 연결, matcher로 spec-reviewer 필터.

set -euo pipefail

INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // "unknown"')

# spec-reviewer의 출력에서 "수정 필요" 또는 "Revisions Needed" 키워드 확인
OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // .stop_reason // ""')

if echo "$OUTPUT" | grep -qiE '수정 필요|Revisions Needed|Request Changes|Critical|Warning'; then
  # Critical/Warning 수 추출 시도
  CRITICAL_COUNT=$(echo "$OUTPUT" | grep -coiE '🔴 Critical|Critical' || echo "0")
  WARNING_COUNT=$(echo "$OUTPUT" | grep -coiE '🟡 Warning|Warning' || echo "0")
  SUGGESTION_COUNT=$(echo "$OUTPUT" | grep -coiE '🔵 Suggestion|Suggestion' || echo "0")

  jq -n \
    --arg critical "$CRITICAL_COUNT" \
    --arg warning "$WARNING_COUNT" \
    --arg suggestion "$SUGGESTION_COUNT" \
    '{
      "title": "Spec Review: Revisions Needed",
      "message": ("*spec-reviewer found issues requiring attention.*\n\n🔴 Critical: " + $critical + "\n🟡 Warning: " + $warning + "\n🔵 Suggestion: " + $suggestion + "\n\nPlease check Claude Code for details and approve/reject each issue."),
      "severity": "warning"
    }' | "$CLAUDE_PROJECT_DIR/.claude/hooks/slack-notify.sh"
fi

exit 0

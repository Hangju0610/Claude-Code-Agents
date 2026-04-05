#!/bin/bash
# .claude/hooks/on-implementation-complete.sh
#
# tdd-implementer 또는 tdd-refactorer가 완료될 때 Slack 알림.
# SubagentStop 이벤트에 연결, matcher로 tdd-implementer|tdd-refactorer 필터.

set -euo pipefail

INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // "unknown"')

# git diff로 변경 요약 수집
DIFF_STAT=$(cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" && git diff --stat HEAD 2>/dev/null | tail -1 || echo "No git changes detected")
CHANGED_FILES=$(cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" && git diff --name-only HEAD 2>/dev/null | head -10 | tr '\n' ', ' || echo "N/A")

# 테스트 결과 요약 (pipeline-context.md에서 추출 시도)
CONTEXT_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/pipeline-context.md"
if [ -f "$CONTEXT_FILE" ]; then
  STAGE=$(grep "현재 단계\|Current stage" "$CONTEXT_FILE" | head -1 | sed 's/.*: //')
else
  STAGE="$AGENT_TYPE completed"
fi

jq -n \
  --arg agent "$AGENT_TYPE" \
  --arg diff_stat "$DIFF_STAT" \
  --arg files "$CHANGED_FILES" \
  --arg stage "$STAGE" \
  '{
    "title": ("Code Complete: " + $agent),
    "message": ("*Stage:* " + $stage + "\n*Changes:* " + $diff_stat + "\n*Files:* `" + $files + "`"),
    "severity": "success"
  }' | "$CLAUDE_PROJECT_DIR/.claude/hooks/slack-notify.sh"

exit 0

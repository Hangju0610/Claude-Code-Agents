#!/bin/bash
# .claude/hooks/on-pipeline-complete.sh
#
# tdd-orchestrator가 완료될 때 최종 결과를 Slack으로 알림.
# SubagentStop 이벤트에 연결, matcher로 tdd-orchestrator 필터.

set -euo pipefail

INPUT=$(cat)

# pipeline-context.md에서 최종 상태 수집
CONTEXT_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/pipeline-context.md"
if [ -f "$CONTEXT_FILE" ]; then
  SPEC=$(grep "기능 명세\|Functional spec" "$CONTEXT_FILE" | head -1 | sed 's/.*: //' || echo "N/A")
  TESTS=$(grep "테스트 파일\|Test files" "$CONTEXT_FILE" | head -1 | sed 's/.*: //' || echo "N/A")
  IMPL=$(grep "구현 파일\|Implementation files" "$CONTEXT_FILE" | head -1 | sed 's/.*: //' || echo "N/A")
else
  SPEC="N/A"
  TESTS="N/A"
  IMPL="N/A"
fi

# git 변경 요약
DIFF_STAT=$(cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" && git diff --stat HEAD 2>/dev/null | tail -1 || echo "N/A")

jq -n \
  --arg spec "$SPEC" \
  --arg tests "$TESTS" \
  --arg impl "$IMPL" \
  --arg diff "$DIFF_STAT" \
  '{
    "title": "TDD Pipeline Complete",
    "message": ("*Full TDD cycle finished!*\n\n*Spec:* " + $spec + "\n*Tests:* " + $tests + "\n*Implementation:* " + $impl + "\n*Changes:* " + $diff),
    "severity": "success"
  }' | "$CLAUDE_PROJECT_DIR/.claude/hooks/slack-notify.sh"

exit 0

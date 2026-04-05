#!/bin/bash
# .claude/hooks/on-test-failure.sh
#
# tdd-implementer가 테스트 통과에 실패하고 재시도 중일 때 Slack 알림.
# SubagentStop 이벤트에 연결, matcher로 tdd-implementer 필터.
# on-implementation-complete.sh와 함께 사용 — 이쪽은 실패 시에만 동작.

set -euo pipefail

INPUT=$(cat)
OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // .stop_reason // ""')

# Green이 아닌 경우 (테스트 실패 잔존)
if echo "$OUTPUT" | grep -qiE 'fail|❌|실패|Red|regression'; then
  if ! echo "$OUTPUT" | grep -qiE '🟢 Green|all tests pass'; then
    
    FAILING=$(echo "$OUTPUT" | grep -iE 'fail|❌' | head -5 | tr '\n' '; ' || echo "Unknown failures")

    jq -n \
      --arg failures "$FAILING" \
      '{
        "title": "TDD Implementer: Tests Failing",
        "message": ("*Implementation did not achieve Green.*\nRetrying or escalating to user.\n\n*Failures:*\n```\n" + $failures + "\n```"),
        "severity": "warning"
      }' | "$CLAUDE_PROJECT_DIR/.claude/hooks/slack-notify.sh"
  fi
fi

exit 0

#!/bin/bash
# .claude/hooks/on-api-docs-complete.sh
#
# api-docs-writer가 완료될 때 Slack 알림.
# SubagentStop 이벤트에 연결, matcher로 api-docs-writer 필터.

set -euo pipefail

INPUT=$(cat)
OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // .stop_reason // ""')

# API 엔드포인트가 없어서 스킵한 경우는 알림하지 않음
if echo "$OUTPUT" | grep -qiE 'unnecessary|not needed|no API|해당 없음'; then
  exit 0
fi

# 문서 작성 완료 시 알림
if echo "$OUTPUT" | grep -qiE 'Documented|Complete|완료'; then
  ENDPOINTS=$(echo "$OUTPUT" | grep -coiE 'POST|GET|PUT|DELETE|PATCH' || echo "N/A")

  jq -n \
    --arg endpoints "$ENDPOINTS" \
    '{
      "title": "API Documentation Complete",
      "message": ("*api-docs-writer finished.*\nEndpoints documented: " + $endpoints + "\n\nSwagger/OpenAPI annotations have been added."),
      "severity": "success"
    }' | "$CLAUDE_PROJECT_DIR/.claude/hooks/slack-notify.sh"
fi

exit 0

#!/bin/bash
# .claude/hooks/on-pipeline-error.sh
#
# 파이프라인 도중 subagent가 실패(Stop 이벤트 + 비정상 종료)할 때 Slack 알림.
# SubagentStop 이벤트에 연결.

set -euo pipefail

INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // "unknown"')
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')

# subagent 결과에서 실패 여부 판단
# Stop 이벤트의 경우 stop_reason을 확인
STOP_REASON=$(echo "$INPUT" | jq -r '.stop_reason // ""')

# 에러 관련 키워드가 포함된 경우만 알림
if echo "$INPUT" | jq -r '.tool_output // .stop_reason // ""' | grep -qiE 'fail|error|block|denied|exception|timeout'; then
  jq -n \
    --arg agent "$AGENT_TYPE" \
    --arg reason "$(echo "$INPUT" | jq -r '.tool_output // .stop_reason // "Unknown error"' | head -c 500)" \
    '{
      "title": ("Pipeline Error: " + $agent),
      "message": ("*Agent:* `" + $agent + "`\n*Details:*\n```\n" + $reason + "\n```"),
      "severity": "error"
    }' | "$CLAUDE_PROJECT_DIR/.claude/hooks/slack-notify.sh"
fi

exit 0

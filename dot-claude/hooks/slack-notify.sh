#!/bin/bash
# .claude/hooks/slack-notify.sh
# 
# Slack Incoming Webhook을 통해 알림을 전송하는 공통 스크립트.
# 모든 hook에서 이 스크립트를 호출한다.
#
# 사용법:
#   echo '{"title":"제목","message":"내용","severity":"info|warning|error|success"}' | .claude/hooks/slack-notify.sh
#
# 환경 변수:
#   SLACK_WEBHOOK_URL - Slack Incoming Webhook URL (필수)
#
# severity별 이모지:
#   info    → ℹ️
#   warning → ⚠️
#   error   → 🔴
#   success → ✅

set -euo pipefail

# Webhook URL 확인
if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  echo "SLACK_WEBHOOK_URL이 설정되지 않았습니다." >&2
  exit 0  # 알림 실패가 파이프라인을 중단하지 않도록 exit 0
fi

# stdin에서 JSON 읽기
INPUT=$(cat)

TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code Notification"')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "No message"')
SEVERITY=$(echo "$INPUT" | jq -r '.severity // "info"')
PROJECT=$(basename "${CLAUDE_PROJECT_DIR:-$(pwd)}")

# severity별 이모지 매핑
case "$SEVERITY" in
  error)   EMOJI="🔴" ;;
  warning) EMOJI="⚠️" ;;
  success) EMOJI="✅" ;;
  *)       EMOJI="ℹ️" ;;
esac

# Slack 페이로드 생성
PAYLOAD=$(jq -n \
  --arg emoji "$EMOJI" \
  --arg title "$TITLE" \
  --arg message "$MESSAGE" \
  --arg project "$PROJECT" \
  --arg timestamp "$(date '+%Y-%m-%d %H:%M:%S')" \
  '{
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": ($emoji + " " + $title)
        }
      },
      {
        "type": "section",
        "fields": [
          {
            "type": "mrkdwn",
            "text": ("*Project:*\n" + $project)
          },
          {
            "type": "mrkdwn",
            "text": ("*Time:*\n" + $timestamp)
          }
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": $message
        }
      }
    ]
  }')

# Slack으로 전송
curl -s -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" > /dev/null 2>&1 || true

exit 0

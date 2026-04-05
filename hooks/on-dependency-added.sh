#!/bin/bash
# .claude/hooks/on-dependency-added.sh
#
# tdd-implementer가 새 라이브러리를 설치할 때 Slack 알림.
# PostToolUse 이벤트에 연결, matcher로 Bash 필터.
# npm install, pip install, go get 등의 패키지 설치 명령을 감지.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# 패키지 설치 명령 감지
if echo "$COMMAND" | grep -qiE 'npm install|yarn add|pip install|go get|cargo add|dotnet add package|brew install'; then
  
  # 설치 명령에서 패키지명 추출 (단순화)
  PACKAGE=$(echo "$COMMAND" | sed 's/.*install\s\+//;s/.*add\s\+//;s/.*get\s\+//' | head -c 200)

  jq -n \
    --arg cmd "$COMMAND" \
    --arg pkg "$PACKAGE" \
    '{
      "title": "New Dependency Installed",
      "message": ("*Package:* `" + $pkg + "`\n*Command:* `" + $cmd + "`\n\nCLAUDE.md should be updated with this dependency."),
      "severity": "info"
    }' | "$CLAUDE_PROJECT_DIR/.claude/hooks/slack-notify.sh"
fi

exit 0

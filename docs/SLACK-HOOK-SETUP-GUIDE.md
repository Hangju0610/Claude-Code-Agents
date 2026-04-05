# Slack Hook 설정 가이드

## 1. Slack Incoming Webhook 생성

### Step 1: Slack App 생성
1. https://api.slack.com/apps 접속
2. **Create New App** → **From scratch** 선택
3. App 이름: `Claude Code Pipeline` (원하는 이름)
4. Workspace 선택 후 **Create App**

### Step 2: Incoming Webhook 활성화
1. 좌측 메뉴에서 **Incoming Webhooks** 클릭
2. **Activate Incoming Webhooks** 토글을 **On**으로 변경
3. 하단의 **Add New Webhook to Workspace** 클릭
4. 알림을 받을 채널 선택 (예: `#claude-pipeline`)
5. **Allow** 클릭

### Step 3: Webhook URL 복사
생성된 URL을 복사한다. 형식:
```
https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
```

---

## 2. 환경 변수 설정

### 방법 A: 쉘 프로필에 추가 (권장)
```bash
# ~/.bashrc 또는 ~/.zshrc에 추가
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T.../B.../XXX..."
```

설정 후 터미널 재시작 또는:
```bash
source ~/.bashrc  # 또는 source ~/.zshrc
```

### 방법 B: .env 파일 사용
프로젝트 루트에 `.env` 파일 생성:
```
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T.../B.../XXX...
```

**주의:** `.env`를 `.gitignore`에 추가하여 커밋되지 않도록 한다.

### 방법 C: Claude Code 실행 시 직접 전달
```bash
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..." claude
```

---

## 3. Hook 파일 설치

### Step 1: hooks 디렉토리 생성 및 스크립트 복사
```bash
mkdir -p .claude/hooks

# 공통 알림 스크립트
cp slack-notify.sh .claude/hooks/

# 이벤트별 스크립트
cp on-pipeline-error.sh .claude/hooks/
cp on-implementation-complete.sh .claude/hooks/
cp on-spec-review-issues.sh .claude/hooks/
cp on-code-review-fail.sh .claude/hooks/
cp on-pipeline-complete.sh .claude/hooks/
cp on-test-failure.sh .claude/hooks/
cp on-dependency-added.sh .claude/hooks/
```

### Step 2: 실행 권한 부여
```bash
chmod +x .claude/hooks/*.sh
```

### Step 3: settings.json에 hooks 등록

`.claude/settings.json`에 `hooks-settings.json`의 내용을 병합한다.

이미 `.claude/settings.json`이 있으면, `hooks` 키를 기존 설정에 추가:
```bash
# 기존 settings.json이 없으면 그대로 복사
cp hooks-settings.json .claude/settings.json

# 기존 settings.json이 있으면 수동으로 hooks 블록을 병합
```

### Step 4: 동작 확인
```bash
# Webhook 연결 테스트
echo '{"title":"Test","message":"Hook setup complete!","severity":"success"}' | .claude/hooks/slack-notify.sh
```

Slack 채널에 메시지가 도착하면 설정 완료.

---

## 4. 전체 파일 구조

```
.claude/
├── agents/
│   ├── spec-reviewer.md
│   ├── tdd-writer.md
│   ├── tdd-implementer.md
│   ├── tdd-refactorer.md
│   ├── code-reviewer-claude.md
│   ├── code-reviewer-codex.md
│   └── tdd-orchestrator.md
├── hooks/
│   ├── slack-notify.sh          # 공통 Slack 전송
│   ├── on-pipeline-error.sh     # 파이프라인 오류
│   ├── on-implementation-complete.sh  # 코드 작성 완료
│   ├── on-spec-review-issues.sh # spec 검토 이슈
│   ├── on-code-review-fail.sh   # 코드 리뷰 실패
│   ├── on-pipeline-complete.sh  # 파이프라인 완료
│   ├── on-test-failure.sh       # 테스트 실패 알림
│   └── on-dependency-added.sh   # 라이브러리 설치 알림
├── settings.json                # hooks 등록
└── pipeline-context.md          # (자동 생성) 파이프라인 상태
```

---

## 5. 알림 매핑 요약

| 이벤트 | Hook 스크립트 | Slack 알림 시점 | 심각도 |
|---|---|---|---|
| 파이프라인 오류 | `on-pipeline-error.sh` | subagent 실패/에러 발생 시 | 🔴 error |
| 코드 작성 완료 | `on-implementation-complete.sh` | implementer/refactorer 완료 시 | ✅ success |
| Spec 검토 이슈 | `on-spec-review-issues.sh` | spec-reviewer가 수정 필요 판정 시 | ⚠️ warning |
| 코드 리뷰 실패 | `on-code-review-fail.sh` | reviewer가 Block/Request Changes 시 | 🔴/⚠️ |
| 파이프라인 완료 | `on-pipeline-complete.sh` | orchestrator 전체 완료 시 | ✅ success |
| 테스트 실패 | `on-test-failure.sh` | implementer가 Green 미달성 시 | ⚠️ warning |
| 라이브러리 설치 | `on-dependency-added.sh` | npm/pip/go 등 패키지 설치 시 | ℹ️ info |

---

## 6. 의존성

- **jq**: JSON 파싱에 필요
  ```bash
  # macOS
  brew install jq
  
  # Ubuntu/Debian
  sudo apt-get install jq
  ```

- **curl**: Slack Webhook 호출에 필요 (대부분 OS에 기본 설치)

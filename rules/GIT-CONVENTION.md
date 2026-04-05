# Git Convention

이 프로젝트의 모든 agent는 아래 Git 규칙을 따른다.

## Branch Strategy

- 작업 브랜치: `feature/{ticket-or-summary}`, `fix/{ticket-or-summary}`, `refactor/{ticket-or-summary}`
- 브랜치명은 소문자 + 하이픈 구분 (예: `feature/user-login-api`)
- main 브랜치에 직접 커밋하지 않는다. 반드시 PR을 통해 병합한다.

## Commit Message Convention (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

| Type | 설명 |
|---|---|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `test` | 테스트 추가/수정 (기능 변경 없음) |
| `refactor` | 코드 리팩토링 (기능 변경 없음) |
| `docs` | 문서 변경 (API docs, README 등) |
| `style` | 포맷팅, 세미콜론 등 (기능 변경 없음) |
| `chore` | 빌드, 설정, 의존성 변경 |
| `ci` | CI/CD 설정 변경 |

### Scope

변경의 영향 범위를 괄호로 표기한다 (선택):
- 예: `feat(auth): add JWT token refresh`
- 예: `fix(api): handle null response in user endpoint`

### Subject

- 50자 이내
- 현재 시제, 명령형 ("add" not "added", "fix" not "fixed")
- 첫 글자 소문자
- 마침표 없음

### Body (선택)

- 72자 줄바꿈
- 왜(WHY) 변경했는지 설명
- 무엇(WHAT)이 변경되었는지는 코드가 설명

### Footer (선택)

- Breaking Change: `BREAKING CHANGE: description`
- 이슈 참조: `Closes #123`, `Refs #456`

### 예시

```
feat(auth): add login endpoint with JWT

Implement POST /api/auth/login that accepts email/password
and returns access + refresh tokens.

Closes #42
```

```
test(auth): add unit tests for login validation

Cover edge cases: empty email, invalid format, short password.
```

```
refactor(user): extract validation logic to shared util

Reduce duplication between user and auth modules.
```

## Commit Timing (언제 커밋하는가)

파이프라인의 각 단계 완료 시 오케스트레이터가 커밋한다:

| 단계 | 커밋 타입 | 예시 |
|---|---|---|
| spec-reviewer 완료 | `docs` | `docs(spec): add user-login functional spec` |
| tdd-writer 완료 | `test` | `test(auth): add login endpoint test cases` |
| tdd-implementer 완료 | `feat` 또는 `fix` | `feat(auth): implement login endpoint` |
| tdd-refactorer 완료 | `refactor` | `refactor(auth): extract token generation logic` |
| api-docs-writer 완료 | `docs` | `docs(api): add swagger annotations for auth endpoints` |
| 의존성 추가 시 | `chore` | `chore(deps): add jsonwebtoken@9.0.0` |

## PR Convention

### PR 제목

커밋 메시지와 동일한 Conventional Commits 형식:
```
feat(auth): implement user login with JWT
```

### PR 설명 템플릿

```markdown
## Summary
{기능 명세 요약}

## Changes
- {변경 사항 1}
- {변경 사항 2}

## Test Coverage
- 요구사항 커버리지: {X}%
- 테스트 케이스: {N}건

## Code Review
- Claude: {Approve/Request Changes/Block}
- Codex: {Approve/Request Changes/Block}

## API Docs
- {Swagger 문서 변경 여부}

## Related
- Spec: {기능 명세 파일}
- Closes #{이슈 번호}
```

### PR 생성 방법

```bash
# GitHub CLI 사용
gh pr create --title "feat(auth): implement user login" --body "..." --base main

# GitLab
glab mr create --title "feat(auth): implement user login" --description "..." --target-branch main
```

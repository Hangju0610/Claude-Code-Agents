# Git Convention

All agents in this project follow the Git rules below.

## Branch Strategy

- Feature branches: `feature/{ticket-or-summary}`, `fix/{ticket-or-summary}`, `refactor/{ticket-or-summary}`
- Branch names use lowercase + hyphens (e.g., `feature/user-login-api`)
- Never commit directly to main. Always merge via PR.

## Commit Message Convention (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

| Type | Description |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `test` | Add/modify tests (no functional change) |
| `refactor` | Code refactoring (no functional change) |
| `docs` | Documentation changes (API docs, README, etc.) |
| `style` | Formatting, semicolons, etc. (no functional change) |
| `chore` | Build, config, dependency changes |
| `ci` | CI/CD config changes |

### Scope

Indicate the area of impact in parentheses (optional):
- e.g., `feat(auth): add JWT token refresh`
- e.g., `fix(api): handle null response in user endpoint`

### Subject

- 50 characters or less
- Present tense, imperative mood ("add" not "added", "fix" not "fixed")
- Lowercase first letter
- No period at end

### Body (optional)

- Wrap at 72 characters
- Explain WHY the change was made
- WHAT changed is explained by the code itself

### Footer (optional)

- Breaking Change: `BREAKING CHANGE: description`
- Issue reference: `Closes #123`, `Refs #456`

### Examples

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

## Commit Timing

The orchestrator commits at each pipeline stage completion:

| Stage | Commit Type | Example |
|---|---|---|
| spec-reviewer complete | `docs` | `docs(spec): add user-login functional spec` |
| tdd-writer complete | `test` | `test(auth): add login endpoint test cases` |
| tdd-implementer complete | `feat` or `fix` | `feat(auth): implement login endpoint` |
| tdd-refactorer complete | `refactor` | `refactor(auth): extract token generation logic` |
| api-docs-writer complete | `docs` | `docs(api): add swagger annotations for auth endpoints` |
| Dependency added | `chore` | `chore(deps): add jsonwebtoken@9.0.0` |

## PR Convention

### PR Title

Same Conventional Commits format as commit messages:
```
feat(auth): implement user login with JWT
```

### PR Description Template

```markdown
## Summary
{functional spec summary}

## Changes
- {change 1}
- {change 2}

## Test Coverage
- Requirement coverage: {X}%
- Test cases: {N}

## Code Review
- Claude: {Approve/Request Changes/Block}
- Codex: {Approve/Request Changes/Block}

## API Docs
- {Swagger doc changes}

## Related
- Spec: {spec file}
- Closes #{issue number}
```

### PR Creation

```bash
# GitHub CLI
gh pr create --title "feat(auth): implement user login" --body "..." --base main

# GitLab CLI
glab mr create --title "feat(auth): implement user login" --description "..." --target-branch main
```

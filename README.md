# TDD Pipeline for Claude Code

A complete TDD development pipeline with 8 specialized subagents, Git convention enforcement, Slack notifications, and dual code review (Claude + Codex).

## Pipeline Flow

```
Branch Create → ① spec-reviewer → ② tdd-writer → ③ tdd-implementer
             → ④ tdd-refactorer → ⑤ api-docs-writer
             → ⑥⑦ code-reviewer (Claude + Codex parallel)
             → Git Push + PR to main
```

## Agents

| # | Agent | Role | Model |
|---|---|---|---|
| ⓪ | `tdd-orchestrator` | Pipeline orchestrator | opus |
| ① | `spec-reviewer` | Spec analysis + design/policy review | sonnet |
| ② | `tdd-writer` | Test writing (Red) | opus |
| ③ | `tdd-implementer` | Minimal implementation (Green) | opus |
| ④ | `tdd-refactorer` | Refactoring (Refactor) | opus |
| ⑤ | `api-docs-writer` | API documentation (Swagger/OpenAPI) | opus |
| ⑥ | `code-reviewer-claude` | Claude code review | sonnet |
| ⑦ | `code-reviewer-codex` | Codex code review | sonnet (Codex CLI) |

## Quick Install

### 1. Copy agents (choose language: en or ko)

```bash
# English version (recommended for token efficiency)
cp -r dot-claude/agents/en/* YOUR_PROJECT/.claude/agents/

# Korean version
cp -r dot-claude/agents/ko/* YOUR_PROJECT/.claude/agents/
```

### 2. Copy hooks, settings, rules

```bash
cp -r dot-claude/hooks YOUR_PROJECT/.claude/
cp dot-claude/settings.json YOUR_PROJECT/.claude/
cp -r dot-claude/rules YOUR_PROJECT/.claude/
chmod +x YOUR_PROJECT/.claude/hooks/*.sh
```

### 3. Set up Slack (optional)

```bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T.../B.../XXX..."
```

See `docs/SLACK-HOOK-SETUP-GUIDE.md` for detailed setup.

### 4. Install Codex plugin (optional, for dual review)

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/codex:setup
```

### 5. Install dependencies

```bash
# jq (required for hooks)
brew install jq  # macOS
sudo apt-get install jq  # Ubuntu

# GitHub CLI (required for PR creation)
brew install gh  # macOS
sudo apt-get install gh  # Ubuntu
```

## Usage

```bash
# Full pipeline
@tdd-orchestrator implement user login with JWT authentication

# Start from specific stage
@tdd-orchestrator start from tdd-writer with spec at docs/login-spec.md

# Code review only
@tdd-orchestrator review the current changes
```

## Folder Structure

```
.claude/
├── agents/              # Subagent definitions
│   ├── spec-reviewer.md
│   ├── tdd-writer.md
│   ├── tdd-implementer.md
│   ├── tdd-refactorer.md
│   ├── api-docs-writer.md
│   ├── code-reviewer-claude.md
│   ├── code-reviewer-codex.md
│   └── tdd-orchestrator.md
├── hooks/               # Slack notification scripts
│   ├── slack-notify.sh
│   ├── on-pipeline-error.sh
│   ├── on-implementation-complete.sh
│   ├── on-spec-review-issues.sh
│   ├── on-code-review-fail.sh
│   ├── on-pipeline-complete.sh
│   ├── on-test-failure.sh
│   ├── on-dependency-added.sh
│   └── on-api-docs-complete.sh
├── rules/               # Project rules (auto-loaded)
│   └── git-convention.md
├── settings.json        # Hook registrations
└── pipeline-context.md  # (auto-generated at runtime)
```

## Notes

- `dot-claude/` in this archive maps to `.claude/` in your project
- English agents consume ~40% fewer tokens than Korean
- Codex plugin is optional — Claude-only review works without it
- All hooks fail silently (exit 0) to never block the pipeline

---
name: command-risk-review
description: Use when deciding whether a Codex CLI command approval request is safe to allow. Classifies commands by impact and permits low-risk automation while preserving human approval for destructive, publishing, deployment, and secret-bypass operations.
---

# Command Risk Review

Use this skill to classify command approval requests and decide whether they can be allowed without interrupting the user.

## Language policy

- Accept user context in Japanese or English.
- Always produce decisions and rationales in English.

## Decision model

Classify each command by the highest-impact action it performs. If a command chains multiple actions, evaluate each segment and use the highest risk level.

## Risk levels

### Safe

Allow without asking when the sandbox already permits it:

- Read-only repository inspection: `git status`, `git diff`, `git log`, `git show`, `rg`, `find`, `ls`, `sed`, `cat`, `nl`, `wc`
- Read-only dependency or environment inspection: `npm ls`, `cargo tree`, `go env`, `python --version`
- Local checks that do not publish or mutate important state: tests, typecheck, lint, build
- Local app/dev server startup when it only binds locally

### Low Risk

Allow when the command is scoped to the workspace and reversible:

- Formatter or linter autofix
- Code generation from checked-in source or local schemas
- Package install that only changes workspace lockfiles or caches
- Starting local services for verification

### Medium Risk

Allow only after the command's purpose and scope are clear:

- `git add` and `git commit` after commit preflight passes
- `git push` only when it is pushing the current feature branch for PR creation
- `gh pr create` after commit/PR preflight passes
- Migration generation, but not migration application to shared environments
- Dependency upgrades

### High Risk

Require human approval:

- `git push --force`, `git push --mirror`, or pushing protected/shared branches
- `gh pr merge`, release creation, deploy, publish, or production changes
- Database migration application against shared/staging/production systems
- Secret scanning bypass, GitHub push protection bypass, or disabling security checks
- Destructive filesystem or git operations: `rm -rf`, `git reset --hard`, `git clean`, branch deletion
- Commands that send broad workspace contents to external services without a clear need

## PR creation policy

PR creation is allowed after preflight because a human will review before merge. The allowed path is:

1. Inspect the diff and staged changes.
2. Run a secret scan or equivalent checks.
3. Confirm the branch is not protected or shared.
4. Push only the current feature branch.
5. Create or update the PR.

Do not merge, auto-merge, release, deploy, or bypass secret protection.

## Output format

```markdown
## Command Risk Review

Decision: allow / ask_human / reject
Risk: safe / low / medium / high
Command: `<command>`
Rationale: <short reason>
Required preflight: <none or checks>
Human approval needed for: <specific action, if any>
```

## Rules

- Prefer mechanical evidence over confidence.
- Treat network publishing as higher risk than local mutation.
- Treat secret-bypass requests as high risk even when a scanner reports a false positive.
- If unsure whether a command publishes, deploys, deletes, or touches credentials, ask the user.

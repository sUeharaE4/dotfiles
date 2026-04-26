---
name: commit-preflight
description: Use before creating commits, pushing a feature branch, or creating a GitHub pull request. Runs a safety checklist for secrets, unintended files, test status, branch target, and PR content.
---

# Commit Preflight

Use this skill to reduce manual interruption around commits and pull request creation while keeping sensitive operations gated.

## Language policy

- Accept user context in Japanese or English.
- Always produce commit messages, PR descriptions, checklists, and summaries in English.

## Scope

This skill covers:

- Preparing a commit
- Creating a commit after checks pass
- Pushing the current feature branch for PR creation
- Creating a GitHub pull request

This skill does not approve:

- PR merge or auto-merge
- Releases, deploys, or package publishing
- Secret scanning or push protection bypass
- Force push or protected branch push

## Commit preflight

Before committing:

1. Inspect `git status --short`.
2. Inspect `git diff` and `git diff --staged`.
3. Check for unintended files: `.env`, credentials, private keys, local config, logs, database dumps, large binaries, generated noise.
4. Run available secret scanning when present, for example `gitleaks`, `detect-secrets`, `trufflehog`, or repo-provided scripts.
5. Run relevant tests or checks for the changed surface.
6. Create a concise English commit message.
7. Commit only intended files.

If secret scanning tools are unavailable, perform a focused textual scan for common secret markers and call out the residual risk.

## PR preflight

Before pushing or creating a PR:

1. Confirm the current branch is a feature branch, not `main`, `master`, `develop`, or another protected/shared branch.
2. Confirm the diff contains only intended changes.
3. Run secret checks again if new changes were made after the commit.
4. Confirm tests or verification status is known.
5. Push only the current feature branch, usually `git push -u origin HEAD`.
6. Create the PR with a clear title and body.
7. Do not merge the PR.

PR creation is allowed after these checks because human review still gates merge. Pushing the feature branch for PR creation is allowed under the same preflight. If GitHub push protection blocks the push, stop and ask the user; do not bypass.

## Secret scan fallback

When no dedicated scanner exists, inspect changed content for:

- API keys, access tokens, refresh tokens, private keys, passwords, cookies, session secrets
- Common names: `SECRET`, `TOKEN`, `PASSWORD`, `PRIVATE_KEY`, `CLIENT_SECRET`, `AWS_`, `GITHUB_TOKEN`, `OPENAI_API_KEY`
- PEM blocks, JWT-like strings, cloud credentials, `.npmrc`, `.pypirc`, `.netrc`

This fallback is weaker than a real scanner. Report that limitation.

## Output format

```markdown
## Commit/PR Preflight

### Diff Scope
- <Intended changes>

### Secret Check
- Tool/result or fallback result

### Verification
- `<command>`: <result>

### Commit
- Message: <commit message>
- Status: created / skipped / blocked

### Pull Request
- Branch: <branch>
- Push: completed / skipped / blocked
- PR: <URL or skipped / blocked>

### Residual Risk
- <Risk or "None known">
```

## Blockers

Stop and ask the user when:

- A possible secret is found.
- The command would bypass secret scanning or push protection.
- The current branch appears protected or shared.
- The PR would include unrelated or unexplained changes.
- Required checks fail in a way that may affect correctness.

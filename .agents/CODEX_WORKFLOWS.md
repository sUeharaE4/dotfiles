# Codex Development Workflows

This guide describes how to use Codex CLI, the shared skills, and the command approval policy for common development work.

The default operating model is:

- Use English for Codex instructions and durable outputs.
- Japanese input is acceptable during requirement discovery.
- Use WezTerm as the terminal workspace.
- Use Codex skills to keep the workflow consistent.
- Let Codex run safe local checks automatically.
- Keep human approval for product decisions, secrets, destructive operations, merges, releases, deploys, and security bypasses.

## Available Skills

- `sdd-spec`: turns fuzzy ideas into English spec documents, while respecting repo-specific spec workflows.
- `spec-review`: reviews specs for ambiguity, missing requirements, UX gaps, risk, and testability.
- `implement-from-spec`: implements scoped changes from a spec or task list.
- `task-autopilot`: implements all tasks in order, reviews the whole feature after tasks complete, fixes accepted findings, then runs commit/PR preflight.
- `review-triage`: classifies review comments as `must_fix`, `should_fix`, `reject`, or `needs_human`.
- `commit-preflight`: checks diff scope, secrets, tests, branch safety, commit, push, and PR creation.
- `command-risk-review`: classifies command approval risk.

## Terminal Setup

Use one WezTerm workspace per repo or feature.

Suggested layout:

```text
Workspace: <repo-or-feature>

Pane 1: main Codex session
  - spec discussion
  - task execution
  - review triage
  - commit/PR preflight

Pane 2: dev server, if useful
  - npm run dev / pnpm dev / rails s / etc.

Pane 3: tests or logs, if useful
  - test watcher
  - typecheck/lint reruns
  - application logs
```

Avoid running many independent Codex sessions unless there is a concrete reason. The main Codex session should normally keep the context and orchestrate subagents or skills.

## Command Approval Policy

The shared Codex hook auto-allows clearly local development checks, such as:

- tests
- lint
- typecheck
- build
- local dev server startup

It blocks clearly dangerous or externally visible operations, such as:

- destructive git or filesystem operations
- force push
- PR merge
- releases
- deploys
- package publishing
- secret scanning or push protection bypass
- public tunnels or binding dev servers to `0.0.0.0`

Ambiguous commands fall back to normal Codex approval.

## Workflow 1: New Application Development

Use this when creating a new application from scratch.

### Goal

Create a clear spec first, review it, implement the first useful version, review the full feature diff, fix accepted findings, then commit and open a PR.

### Steps

1. Create or enter the repo.
2. Start Codex in the repo.
3. Use `sdd-spec` to shape the idea into a spec.
4. Use `spec-review` to review the spec before implementation.
5. Apply accepted spec review feedback.
6. Generate or confirm implementation tasks.
7. Use `task-autopilot` to implement tasks in order.
8. After all tasks complete, review the whole feature diff.
9. Use `review-triage` to classify findings.
10. Fix `must_fix` and in-scope `should_fix` findings.
11. Run verification again.
12. Use `commit-preflight`.
13. Commit and create a PR if preflight passes.

### Starting Prompt

```text
Use sdd-spec.

I want to create a new application from scratch. I may explain the idea in Japanese, but ask questions and write all durable outputs in English.

<describe the application idea>

If this repo has no existing spec workflow, ask whether to create a spec document.
After the spec is ready, review it, apply accepted spec review feedback, create tasks, then use task-autopilot to implement all tasks.

After all tasks are complete, review the whole feature diff, triage findings, fix accepted issues, run verification, then run commit-preflight.
Create a commit and a GitHub PR if preflight passes.

Do not merge, deploy, release, force push, or bypass secret protection.
```

### Human Decision Points

Codex should stop for:

- unresolved product decisions
- conflicting UX or architecture choices
- possible secrets
- failed checks requiring product judgment
- `needs_human` review findings
- merge, release, deploy, force push, or security bypass requests

## Workflow 2: Large Feature Addition to an Existing Application

Use this for larger changes where a spec or task workflow is appropriate.

This includes repos using:

- spec workflow MCP
- Kiro
- Spec Kit
- custom RFC/spec/task files
- repo-specific templates

### Goal

Respect the repository's existing spec workflow, implement all approved tasks, then review and publish the full feature safely.

### Steps

1. Start Codex in the target repo.
2. Ask Codex to detect the repo's spec workflow.
3. Use the repo's standard workflow to create or update spec/design/tasks.
4. Review the spec if the change is product-significant.
5. Use `task-autopilot` after tasks are created.
6. Run targeted verification per task.
7. Run feature-level verification after all tasks complete.
8. Review the full feature diff.
9. Triage findings.
10. Fix accepted findings.
11. Re-run verification.
12. Run commit/PR preflight.
13. Commit and create a PR if preflight passes.

### Starting Prompt

```text
Use the repository's existing spec workflow.

Detect whether this repo uses spec workflow MCP, Kiro, Spec Kit, or a custom spec/task convention.
Follow that workflow instead of creating a parallel generic spec.

Feature:
<describe the feature>

After the workflow creates or updates tasks, use task-autopilot:
- implement all tasks in order
- run targeted verification per task
- do not run full review after every task
- after all tasks complete, run feature-level verification
- review the whole diff
- triage findings
- fix must_fix and in-scope should_fix findings
- re-run verification
- run commit-preflight
- create a commit and PR if preflight passes

Do not merge, deploy, release, force push, or bypass secret protection.
```

### When No Spec Exists

If the repo does not currently use spec documents, Codex should ask whether to create one.

If the user says no, Codex should proceed from:

- the current task description
- issue or PR context
- clarified requirements from the conversation
- existing project behavior

Codex should not create spec files just because none exist.

## Workflow 3: Small and Simple Fixes

Use this for narrow changes such as:

- typo fixes
- small bug fixes
- localized refactors
- one-file or low-risk changes
- dependency or config tweaks with clear scope

### Goal

Avoid overusing specs. Implement the fix directly, verify it, run lightweight review if appropriate, then commit or prepare a PR.

### Steps

1. State the small fix clearly.
2. Let Codex inspect the relevant files.
3. Implement the minimal change.
4. Run the narrowest useful verification.
5. Run a lightweight review if the change affects behavior.
6. Fix any clear issue.
7. Run `commit-preflight`.
8. Commit and create a PR if requested.

### Starting Prompt

```text
This is a small fix. Do not create a spec unless you find the scope is larger than expected.

Task:
<describe the fix>

Make the minimal change, run the narrowest relevant verification, and call out any residual risk.
If the diff affects behavior, do a lightweight review before commit-preflight.
After verification passes, run commit-preflight and create a commit.
Create a PR if preflight passes and the change is ready for review.

Do not merge, deploy, release, force push, or bypass secret protection.
```

### Escalate to the Large Feature Workflow When

- the fix expands into multiple user-visible behaviors
- requirements are ambiguous
- data model or API contracts change
- migrations are needed
- security, privacy, permissions, or billing are affected
- acceptance criteria are unclear

## Review Strategy

For small tasks inside a larger feature, do not review after every task by default.

Preferred strategy:

```text
task 1 implementation
→ targeted verification
task 2 implementation
→ targeted verification
...
all tasks complete
→ feature-level verification
→ whole-diff review
→ review triage
→ accepted fixes
→ re-verification
→ commit/PR preflight
```

This reduces review noise and gives the reviewer the full feature context.

## Commit and PR Strategy

Commit and PR creation are allowed after `commit-preflight`.

Preflight must check:

- intended diff scope
- secrets or sensitive local files
- branch safety
- verification status
- commit message
- PR title and body

Allowed after preflight:

- `git add` for intended files
- `git commit`
- pushing the current feature branch
- `gh pr create`

Still requires human approval:

- PR merge
- release
- deploy
- package publish
- force push
- secret scanning or push protection bypass

## Practical Defaults

Use these defaults unless a repo says otherwise:

- New app: create a spec.
- Large feature: use the repo's existing spec workflow.
- Existing repo with no spec workflow: ask before creating spec files.
- Small fix: no spec.
- Fine-grained tasks: review after all tasks complete.
- PR creation: allowed after preflight.
- Merge: human only.

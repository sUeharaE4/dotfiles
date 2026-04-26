---
name: task-autopilot
description: Use to execute a feature from spec workflow tasks with minimal user interruption. Implements all tasks in order, runs targeted verification per task, reviews the whole feature after all tasks are done, fixes accepted findings, then runs commit/PR preflight.
---

# Task Autopilot

Use this skill when the repository already has task artifacts from a spec workflow, such as spec workflow MCP, Kiro, Spec Kit, or a custom task list.

This skill orchestrates existing skills:

- Use `implement-from-spec` behavior for implementation planning and scoped edits.
- Use `review-triage` behavior after feature-level review findings are available.
- Use `commit-preflight` behavior before commit, push, or PR creation.
- Use `command-risk-review` behavior when a command approval decision is needed.

## Language policy

- Accept user context in Japanese or English.
- Always produce task status, review decisions, commit messages, PR text, and final summaries in English.
- Do not translate code identifiers or product strings unless the spec requires it.

## Core policy

Run the review loop after all planned tasks are complete, not after every task, when the tasks are intentionally small.

Per-task work should use targeted verification only. Feature-level review should evaluate the complete diff against the spec, design, tasks, and existing project behavior.

## Workflow

1. Resolve the active spec workflow and task source.
2. Read the relevant spec, design, plan, task list, and repository guidance.
3. Build an execution queue from incomplete tasks.
4. Implement tasks in order.
5. After each task, run targeted verification appropriate to the touched surface.
6. Record task completion notes and any assumptions.
7. After all tasks are complete, run feature-level verification.
8. Run a whole-diff code review using the available reviewer mechanism or reviewer subagent.
9. Use review-triage rules to classify findings.
10. Fix `must_fix` and in-scope `should_fix` findings.
11. Re-run verification.
12. Run a focused second review only if the fixes were substantial or risky.
13. Run commit-preflight.
14. Create a commit and, if requested or consistent with the user's workflow, create a GitHub PR.

Do not merge, deploy, release, force push, or bypass secret protection.

## Task source resolution

Inspect sources in this order:

1. Explicit user instruction in the current turn.
2. Repository guidance: `AGENTS.md`, `.codex/AGENTS.md`, `.agents/AGENTS.md`, `CLAUDE.md`, or project docs.
3. spec workflow MCP task state and artifacts when available.
4. Kiro artifacts: `.kiro/specs/<feature>/requirements.md`, `design.md`, `tasks.md`.
5. Spec Kit artifacts: `specs/<feature>/spec.md`, `plan.md`, `tasks.md`, and supporting files.
6. Custom task files under paths such as `docs/specs/`, `docs/tasks/`, `rfcs/`, `proposals/`, or issue-linked docs.

If no task source is found, ask for the task path or whether to proceed from the current request without a task file. Do not invent a task workflow silently.

## Per-task execution

For each task:

- Confirm the task is still relevant to the current spec.
- Implement the smallest change that satisfies the task.
- Avoid broad refactors unless the task requires them.
- Run targeted checks such as the affected unit test, typecheck for the touched package, lint for edited files, or a narrow manual verification.
- Mark the task complete only when the targeted check passes or the residual risk is explicitly documented.

Do not run a full code review after each task unless the user asks or the task is unusually risky.

## Feature-level review loop

After all tasks are complete:

1. Inspect the full diff against the base branch.
2. Run repository-level verification appropriate to the feature.
3. Review the full diff for correctness, security, data loss, broken UX, missing tests, spec violations, and regressions.
4. Classify findings:
   - `must_fix`: fix before commit/PR.
   - `should_fix`: fix when in-scope and low churn.
   - `reject`: do not change; optionally prepare a PR response.
   - `needs_human`: stop and ask the user.
5. Apply accepted fixes.
6. Re-run failed or relevant checks.

If a second review finds only non-blocking or rejected issues, proceed to commit-preflight.

## Human escalation

Stop and ask the user when:

- The spec or task list has unresolved product decisions.
- Implementation reality contradicts the spec.
- A likely secret, private key, token, credential, or sensitive local file appears in the diff.
- Required checks fail and the fix requires product or architectural judgment.
- Review triage produces `needs_human`.
- The branch appears protected or shared.
- A command would merge, deploy, release, force push, delete important data, or bypass security protection.

## Commit and PR policy

Commit and PR creation are allowed after preflight:

- Commit only intended files.
- Use an English commit message.
- Push only the current feature branch for PR creation.
- Create the PR with an English title and body.
- Do not merge the PR.

If secret scanning or GitHub push protection blocks the push, stop. Do not bypass.

## Status output

Use this concise status format during long runs:

```markdown
## Task Autopilot Status

Current phase: <task execution / feature verification / review / fixes / preflight / PR>
Task progress: <done>/<total>
Current task: <task id or title>
Verification: <latest check and result>
Blocked on: <none or issue>
```

## Final output

```markdown
## Task Autopilot Complete

### Tasks
- <Task>: completed / skipped / blocked

### Review
- Findings: <count by classification>
- Fixes applied: <summary>

### Verification
- `<command>`: <result>

### Commit/PR
- Commit: <hash or skipped / blocked>
- PR: <URL or skipped / blocked>

### Residual Risk
- <Risk or "None known">
```

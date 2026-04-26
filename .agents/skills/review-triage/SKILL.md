---
name: review-triage
description: Use to evaluate code review comments against the spec, diff, and project constraints. Classifies comments as must fix, should fix, reject, or needs human decision.
---

# Review Triage

Use this skill after a code review or `/review` result to decide which comments should drive implementation changes.

## Language policy

- Accept review comments, specs, and discussion in Japanese or English.
- Always produce triage output in English.
- If a Japanese review comment is ambiguous, translate the likely meaning into English and call out the uncertainty.

## Inputs to inspect

- The review comments
- The spec or task document
- The current diff against the base branch
- Relevant tests and project conventions
- Prior decisions or explicitly accepted tradeoffs

## Spec source resolution

Before classifying comments, identify the authoritative spec source:

- Explicit user instruction wins.
- Check `AGENTS.md`, `.codex/AGENTS.md`, `.agents/AGENTS.md`, `CLAUDE.md`, and project docs for the repo's spec workflow.
- Kiro-style repos usually require checking `.kiro/specs/<feature>/requirements.md`, `design.md`, and `tasks.md`.
- Spec Kit repos usually require checking `specs/<feature>/spec.md`, `plan.md`, `tasks.md`, and supporting artifacts when present.
- spec workflow MCP repos should use MCP workflow state and artifacts when available.
- If no spec exists, classify comments against the stated task, PR description, tests, and established project behavior, and call out the missing spec as residual risk.

## Classification

Classify each review comment into exactly one bucket:

- `must_fix`: Correctness, security, data loss, broken UX, failing tests, spec violation, or high regression risk.
- `should_fix`: Valid maintainability, test coverage, performance, or UX improvement that fits the PR scope.
- `reject`: Incorrect, already handled, contradicts the spec, out of scope, or style-only without meaningful value.
- `needs_human`: Product, design, policy, migration, or risk decision that should not be decided by the agent alone.

## Workflow

1. Normalize each review comment into a concise English claim.
2. Check whether the claim is supported by the diff and existing code.
3. Compare it with the spec, acceptance criteria, and known constraints.
4. Assign one classification and a short rationale.
5. For accepted comments, propose the smallest implementation action.
6. For rejected comments, explain the evidence clearly enough to support a reply.
7. For human decisions, provide the decision options and tradeoffs.

## Output format

```markdown
## Review Triage

### Detected Spec Source
<Path, workflow, or "No explicit spec found">

### Must Fix
- Comment: <normalized comment>
  Decision: must_fix
  Rationale: <evidence>
  Action: <smallest change>

### Should Fix
- Comment: <normalized comment>
  Decision: should_fix
  Rationale: <evidence>
  Action: <smallest change>

### Reject
- Comment: <normalized comment>
  Decision: reject
  Rationale: <evidence>
  Suggested reply: <optional PR response>

### Needs Human Decision
- Comment: <normalized comment>
  Decision: needs_human
  Rationale: <why agent should not decide>
  Options: <concise choices and tradeoffs>

### Recommended Next Patch
- <Ordered implementation steps>
```

If a bucket is empty, omit it except when all comments are rejected.

## Rules

- Do not accept review comments just because they are phrased confidently.
- Do not reject comments without checking the diff or spec when available.
- Keep recommended patches small and directly tied to accepted comments.
- If asked to implement the accepted comments, use the repository's normal editing and verification workflow.

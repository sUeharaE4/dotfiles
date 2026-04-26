---
name: implement-from-spec
description: Use when implementing a feature from an English spec or task list. Plans, edits, tests, and reports against the spec while keeping scope controlled.
---

# Implement From Spec

Use this skill to implement a feature from a spec, task list, or reviewed design document.

## Language policy

- Accept user instructions and source context in Japanese or English.
- Always produce implementation plans, task updates, commit/PR text, and final summaries in English.
- Do not translate code identifiers or user-facing strings unless the spec requires it.

## Workflow

1. Resolve the repository's spec workflow and artifact locations.
2. Read the spec, tasks, and any linked review notes.
3. Identify the smallest coherent implementation slice.
4. Map likely files and existing patterns before editing.
5. Create a short plan with explicit verification steps.
6. Implement only behavior covered by the spec or clearly required by existing contracts.
7. Add or update tests proportional to the risk.
8. Run the most relevant checks available in the repository.
9. Compare the final diff against the spec before reporting completion.

## Spec source resolution

Before planning implementation, inspect the repo's spec conventions:

- Explicit user instruction wins.
- Use guidance from `AGENTS.md`, `.codex/AGENTS.md`, `.agents/AGENTS.md`, `CLAUDE.md`, or project docs when present.
- For Kiro-style repos, read `.kiro/specs/<feature>/requirements.md`, `design.md`, and `tasks.md` together.
- For Spec Kit repos, read the relevant `specs/<feature>/spec.md`, `plan.md`, `tasks.md`, and supporting artifacts such as `research.md`, `data-model.md`, `contracts/`, or `quickstart.md` when present.
- For spec workflow MCP repos, prefer MCP-provided artifacts and workflow state when tools are available; otherwise inspect existing files and call out the fallback.
- For custom repos, follow local templates and task files.

If no spec artifact can be found, ask whether the user wants to create a spec document for this work. If the user says no, proceed from the current task description, PR context, issue text, or clarified requirements without creating spec files. Call out that there is no explicit spec source in the implementation plan.

## Scope control

- Treat the spec as the source of truth.
- If the spec is ambiguous, choose the least surprising behavior only when the risk is low; otherwise stop and ask.
- Do not expand scope to adjacent refactors, cleanup, or new abstractions unless needed to satisfy the spec safely.
- Preserve unrelated user changes in the working tree.
- When multiple agents or sessions are active, do not revert changes you did not make.

## Implementation plan format

```markdown
## Implementation Plan
- <Step>

## Detected Spec Workflow
<Kiro / Spec Kit / spec workflow MCP / custom / generic / unknown>

## Files Likely Involved
- <path>: <why>

## Verification
- <command or manual check>
```

## During implementation

- Prefer existing repository patterns over new architecture.
- Keep public API and data contract changes explicit.
- Add regression tests for changed behavior when feasible.
- For UI work, cover important states from the spec: empty, loading, success, and error.
- For migrations or destructive operations, call out risk before proceeding.

## Completion report

Use this structure:

```markdown
## Completed
- <What changed>

## Verification
- `<command>`: <result>

## Spec Coverage
- <Requirement or acceptance criterion>: <covered / partial / not covered>

## Remaining Risks
- <Risk or "None known">
```

If checks could not be run, explain exactly why and identify the residual risk.

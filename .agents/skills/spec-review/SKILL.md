---
name: spec-review
description: Use to review an English feature spec before implementation. Checks ambiguity, missing requirements, UX gaps, risk, testability, and implementation readiness.
---

# Spec Review

Use this skill to review a specification before implementation starts.

## Language policy

- Accept context in Japanese or English.
- Always produce the review in English.
- If a Japanese phrase carries important product nuance, quote it briefly and explain the risk in English.

## Review stance

Review like an engineer who will be accountable for the resulting implementation. Prioritize gaps that could cause rework, incorrect behavior, poor UX, unsafe changes, or untestable acceptance criteria.

Do not bikeshed wording unless unclear wording creates a real implementation or product risk.

## Inputs to inspect

- The spec document
- Linked designs, issue text, product notes, or user-provided context
- Relevant repository conventions when available
- Existing APIs, data models, or workflows if the spec depends on them

## Repo spec workflow detection

Before reviewing, identify the repository's expected spec workflow:

- Check explicit user instruction first.
- Check `AGENTS.md`, `.codex/AGENTS.md`, `.agents/AGENTS.md`, `CLAUDE.md`, and project docs for spec conventions.
- Look for Kiro artifacts under `.kiro/specs/**/requirements.md`, `design.md`, and `tasks.md`.
- Look for Spec Kit artifacts such as `.specify/`, `specs/**/spec.md`, `plan.md`, and `tasks.md`.
- Look for spec workflow MCP configuration in `.codex/config.toml` or other MCP config files.
- If the repo uses a custom workflow, review against that workflow's templates and naming.

When a repo-specific workflow exists, review the spec against that workflow. Do not ask the author to move to the generic SDD format unless the repo has no clear standard.

## Review checklist

- Goal clarity: Is the problem and intended outcome clear?
- Scope: Are goals and non-goals explicit enough?
- User experience: Are primary, empty, loading, success, and error states covered?
- Behavior: Are functional requirements precise and observable?
- Edge cases: Are boundary cases and failure modes addressed?
- Data/API: Are contracts, persistence, migrations, and compatibility constraints clear?
- Security/privacy: Are permissions, sensitive data, and abuse cases covered where relevant?
- Operations: Are logging, analytics, rollout, and monitoring needs clear when relevant?
- Testability: Can acceptance criteria become tests?
- Implementation readiness: Can an implementer start without inventing product behavior?

## Output format

Use this structure:

```markdown
## Spec Review

### Blocking Issues
- [High] <Issue>
  Impact: <Why this matters>
  Suggested resolution: <Concrete change>

### Non-Blocking Improvements
- [Medium/Low] <Issue>
  Suggested resolution: <Concrete change>

### Clarifying Questions
- <Question>

### Ready-to-Implement Assessment
<Ready / Ready with assumptions / Not ready>

### Detected Workflow
<Kiro / Spec Kit / spec workflow MCP / custom / generic / unknown>

### Suggested Spec Edits
- <Specific text or section-level edit>
```

If there are no blocking issues, say so explicitly and list the remaining assumptions.

## Rules

- Do not rewrite the entire spec unless asked.
- Do not start implementation.
- Keep findings grounded in concrete sections or missing sections.
- Prefer fewer, higher-signal findings over exhaustive commentary.

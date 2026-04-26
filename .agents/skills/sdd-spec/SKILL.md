---
name: sdd-spec
description: Use when turning a fuzzy feature idea into an English Spec Driven Development document. Detect repo-specific spec workflows first, accept Japanese input for discovery, and always produce written outputs in English.
---

# SDD Spec

Use this skill to help the user shape an ambiguous feature idea into an implementation-ready specification.

## Language policy

- Accept user input in Japanese or English.
- If the user uses Japanese, infer intent carefully and ask follow-up questions in English.
- Always write durable outputs in English: spec documents, decisions, assumptions, acceptance criteria, task lists, and summaries.
- Preserve domain-specific Japanese terms only when translating them would lose product meaning. Add a short English gloss on first use.

## Workflow

1. Resolve the repository's spec workflow before choosing an output format.
2. Establish the feature goal in one or two English sentences.
3. Identify the target users, primary workflow, and expected user experience.
4. Ask only the highest-value clarifying questions. Prefer grouped questions over a long interview.
5. Separate confirmed decisions from assumptions.
6. Convert the result into the repository's expected spec artifacts.
7. Mark unresolved items explicitly instead of silently choosing risky behavior.

## Repo spec workflow detection

Before writing or updating a spec, inspect the repository in this order:

1. User instruction in the current turn. If the user names a workflow, use it.
2. Repository guidance files such as `AGENTS.md`, `.codex/AGENTS.md`, `.agents/AGENTS.md`, `CLAUDE.md`, or project documentation that defines the spec process.
3. Repo-local config or tool markers:
   - Kiro: `.kiro/specs/**/requirements.md`, `.kiro/specs/**/design.md`, `.kiro/specs/**/tasks.md`
   - Spec Kit: `.specify/`, `specs/**/spec.md`, `specs/**/plan.md`, `specs/**/tasks.md`
   - spec workflow MCP: `.codex/config.toml` or other MCP config naming a spec workflow server, plus existing MCP-managed spec artifacts
   - Custom workflow: `docs/specs/`, `docs/adr/`, `rfcs/`, `proposals/`, or templates that clearly define local conventions
4. Existing nearby feature specs. Reuse their structure and naming when the workflow is clear.
5. If no workflow is identifiable and no existing spec artifacts are present, ask whether the user wants to create a spec document for this work.

When repo guidance conflicts with a generic template, repo guidance wins. Do not create a new parallel spec style in a repository that already uses Kiro, Spec Kit, spec workflow MCP, RFCs, ADRs, or another clear standard.

## Workflow-specific behavior

- Kiro-style repos: create or update the feature folder under `.kiro/specs/<feature>/` and keep requirements, design, and tasks separate.
- Spec Kit repos: create or update the feature folder under the existing `specs/` convention and keep product requirements in `spec.md`, technical planning in `plan.md`, and execution steps in `tasks.md`.
- spec workflow MCP repos: prefer MCP-provided workflow steps and artifacts when available. If the MCP tools are unavailable, inspect existing artifacts and ask before falling back to generic files.
- Custom repos: follow the repository's templates, filenames, headings, and requirement style.
- Unknown repos: state that no repo-specific spec workflow was found. Ask whether to create a spec document. If the user says no, keep the clarified requirements in the conversation and do not create spec files.

## Clarifying question priorities

Ask about these areas when they are unclear:

- User and business goal
- Current pain or workflow being changed
- In-scope and out-of-scope behavior
- Main happy path
- Edge cases and failure states
- Data model or persistence expectations
- Compatibility and migration requirements
- Security, privacy, permission, or abuse concerns
- UI/UX expectations, including empty/loading/error states
- Observability, logging, analytics, or operational needs
- Testability and release constraints

## Spec format

Use this structure only when no repository-specific workflow or template is found and the user wants a spec document:

```markdown
# Feature Spec: <name>

## Summary
<One concise paragraph.>

## Goals
- <Goal>

## Non-Goals
- <Explicitly excluded behavior>

## Users and Use Cases
- <User / scenario / motivation>

## User Experience
### Primary Flow
1. <Step>

### States
- Empty:
- Loading:
- Success:
- Error:

## Functional Requirements
- FR-001: <Requirement>

## Non-Functional Requirements
- NFR-001: <Requirement>

## Data and API Considerations
- <Models, API contracts, migrations, compatibility>

## Edge Cases
- <Case and expected behavior>

## Acceptance Criteria
- AC-001: Given <context>, when <action>, then <observable result>.

## Test Plan
- Unit:
- Integration:
- E2E/manual:

## Risks and Open Questions
- Risk:
- Open question:

## Implementation Notes
- <Constraints, likely files, sequencing hints, or migration notes>
```

## Quality bar

- Requirements must be observable and testable.
- Acceptance criteria must describe behavior, not implementation.
- Keep the spec narrow enough for a pull request unless the user explicitly wants a larger roadmap.
- Do not start implementation from this skill unless the user asks to proceed.
- Mention the detected workflow in the output before the spec content, for example: `Detected spec workflow: Spec Kit`.
- Do not create a spec file just because none exists. If the repository does not normally use spec documents, ask first and respect a "no spec document" decision.

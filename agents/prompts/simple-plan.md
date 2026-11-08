---
description: Research, refine, design, review, and finalize an implementation plan before seeking approval
argument-hint: "<task-or-feature>"
---

Plan mode is active for:

```text
$ARGUMENTS
```

Until the user explicitly approves the final plan, do not implement the task or make system changes. Use read-only actions for investigation. The only file you may create or edit is the plan file (including creating its parent directory):

```text
.agents/plans/FEATURE-NAME-MMDDYY.md
```

Choose a short feature name and use the current local date. If a plan for this task already exists, continue it rather than replacing it.

The plan file is the durable design and implementation artifact, not a transcript or scratchpad of the planning process. Keep it focused on the chosen design, implementation-relevant findings and decisions, concrete implementation work, and verification. Do not preserve discarded ideas, question-and-answer history, review commentary, or other process notes.

The six stages below describe the workflow for producing and approving the plan, not the plan's format. Do not copy these stages into the plan as headings or implementation phases. The final plan's structure and number of implementation phases must follow from the task itself; research, refinement, design, review, finalization, and approval are not implementation phases unless the requested work genuinely requires them.

## Stage 1: Research

Gain an initial understanding of the request and the repository before proposing a solution.

- Read the relevant instructions, documentation, code, configuration, and tests.
- Trace the affected code paths, entry points, consumers, and existing patterns.
- Identify the requested outcome, likely scope, constraints, missing context, ambiguities, and assumptions.
- Record only verified findings that materially inform the design or implementation in the plan file. Track open questions in the conversation until they are resolved; do not turn the plan into a research log.

## Stage 2: Refinement

Grill the user to eliminate consequential ambiguity and validate assumptions. Assumptions are risks, not facts.

- Ask focused questions whose answers could change the scope, behavior, or implementation approach.
- Surface context discovered during research that the user may not have considered or known to provide.
- Do not silently choose between plausible interpretations.
- Update the plan only with resolved decisions, confirmed assumptions, constraints, and explicit non-goals that affect the design or implementation.
- Repeat research and refinement until no unresolved question can materially alter the design.

## Stage 3: Design

Design the smallest coherent approach that satisfies the refined request.

- Reuse existing repository patterns and integration points where practical.
- Consider meaningful tradeoffs such as simplicity, correctness, maintainability, compatibility, performance, and migration impact.
- Compare alternatives only when more than one approach is genuinely viable.
- Select an approach and document its rationale, affected files or symbols, implementation sequence, risks, and verification strategy.

## Stage 4: Review

Challenge the design before finalizing it.

- Re-check the design against the user's intent and the actual repository.
- Verify referenced files, symbols, interfaces, commands, call sites, and integration points.
- Look for missed code paths, unsupported assumptions, unnecessary complexity, and incomplete verification.
- When an external reviewer is available, ask a read-only subagent, advisor, or equivalent to critique the design. Treat its feedback as advisory and verify it yourself.
- Return to an earlier stage if review exposes missing research, ambiguity, or a flawed design. Incorporate the resulting corrections without preserving review commentary in the plan.

## Stage 5: Final Plan

Turn the reviewed design into a concise, implementation-ready living todo list.

The final plan must include:

- The goal and observable success criteria.
- In-scope and out-of-scope work.
- Relevant findings, constraints, and resolved decisions.
- Logical, ordered implementation phases derived from the actual work, with no prescribed phase count. Each phase must include:
  - A short description of its goal and relationship or dependency on other phases.
  - [ ] A checklist of files to create or change, with important symbols where known.
  - Optional types, interfaces, or signatures for crucial changes.
  - [ ] A checklist of specific implementation tasks.
  - [ ] A checklist of exact automated or manual verification steps, including expected outcomes such as passing typechecks or conforming to established repository patterns.
- A **Notes** subsection for relevant API research, integration points, risks, dependencies, migrations, or other implementation considerations.

Keep all implementation checkboxes unchecked. Before presenting the final plan, remove any process-oriented notes so the document focuses on the design and its planned implementation rather than how the plan was produced. Keep the plan concise, but include everything an implementation agent needs to execute it without additional context or repeated investigation. Do not add speculative work.

## Stage 6: Approval

Present the plan path and a brief summary of the approach and important tradeoffs. Ask the user to approve, revise, or reject it.

Do not implement until approval is explicit. If the user requests revisions, return to the relevant stage, update the plan, and request approval again.

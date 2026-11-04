---
name: bug-hunt
description: Rigorously review code for bugs and logic errors. Use when the user asks to find bugs or review code changes for bugs.
---

# Bug Hunt

Attack code to find and source bugs. You are not concerned with styling changes, consistency in design, spaghetti or complexity.

## Core Prompt

> You are a bug hunter, born to attack code and find bugs. You are not distracted by styling failures, spgahetti code
> or complexity - you live to find bugs. Given a changeset, investigate it for bugs and untested edge cases.
> Flag bugs your analysis finds, and raise flags when you discover missed edge cases or untested code.

## Critical Bug Types

A few bug types stand out as critical in nature - the bug hunter finds and reveals all bugs, but pays particular attention to the critical bug types, due to their propensity to go unnoticed.

### Proximate Bug

Pay attention to a particular trap that code can find itself in, solving a proximate cause as opposed to the ultimate cause.
A proximate cause is the immediately noticed problem while ultimate is the originator of a chain of events.

Consider these examples:

<example_one>
PROBLEM: Room is too hot.
PROXIMATE CAUSE: Heat energy coming in is greater than heat energy leaving.
PROPOSED SOLUTION: Open windows and turn on the fans to increase the amount of heat leaving.
ULTIMATE CAUSE: The thermostat is set too high.
REAL SOLUTION: Turn down the thermostat.
</example_one>

<example_two>
PROBLEM: Boat is sinking.
PROXIMATE CAUSE: Gravity is stronger than buoyancy
SOLUTION: Reduce gravity by lightening the boat.
ULTIMATE CAUSE: The boat has a hole in the hull.
REAL SOLUTION: Repair the hole in the hull.
</example_two>

In both of the above examples, the proximate cause falls into a "local minima" of the problem-solution space, and incorrectly identifies the root cause of an issue.

Ensure and validate that the code being proposed does not fall into this trap. Flag these as critical bugs, as solving a proximate cause creates on-flow bugs and does not address the original problem.

### Logic Bug

Logical bugs appear when the code runs without errors but produces incorrect outcomes due to flawed reasoning or misapplied business logic. These are often introduced when conditions, loops, or calculations are implemented incorrectly.

For example, a payroll application might continue to calculate bonuses for employees who have already left the company because the logic for checking employment status was placed after the calculation block. Logical bugs are difficult to identify through surface-level testing since the system appears to function normally.

### Scale Bug

Scale bugs occur when a code change has not considered the efficiency and resiliency of the code in it's deployment environments - unoptimized queries, memory leaks or inefficient resource management kill projects.

For example, a reporting dashboard might load data quickly in testing but slow down significantly when thousands of users query it simultaneously in production. These issues often surface only during stress or load testing, making early performance monitoring crucial.

### Integration Bug

Integration bugs arise when code crosses ownership boundaries, such as through REST APIs, Code SDKs or even internal software APIs. Often these bugs are due to invalid assumptions in how a third party reacts or will continue to react, and are the result of edge-cases being exercised.

For example, a feature might work smoothly in test with quality-assurance data, but break once deployed and run against production data pipelines, that have a different data shape and morph over time.

## Workflow

1. Establish branch intent:
   - Read the current branch, default branch, remotes, and upstream tracking state.
   - If on `main` or `master`, stop and ask for source and target branches.
   - If on another branch, use the current branch as source and default branch as target unless the user specified otherwise.
2. Fan subagents out to understand the change:
   - Use subagents where possible to protect the bug hunter's context window
   - Direct subagents to
     - Diff source against target with commit summaries and full file changes.
     - Analyze test-cases and coverage of edge-cases as well as the happy-path
     - Read relevant files when the diff alone is not enough.
     - Read linked issues, tickets, or specs from branch names, commit messages, and changed docs when discoverable.
     - Report down the why, what, risk areas, verification evidence, and locations of what has changed
3. Extrapolate bug areas
   - Identify areas bugs may be hiding based on subagent reports
   - Consider critical bug types but also
4. Hunt
   - Hunt down the bugs
   - Test the code as required
   - Triage found bugs with a severity and likelihood of being realised/executed
5. Report
   - Report to the user any found bugs, ordered in severity.
   - Triage found bugs for false-positives

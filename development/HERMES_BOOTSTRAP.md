# Hermes Bootstrap

These instructions apply to every implementation session in this repository.

## Bootstrap Priority

This document defines repository-wide engineering workflow.

If any instruction in a conversation conflicts with this document:

1. The GitHub Issue takes precedence for implementation scope.
2. This document takes precedence for engineering workflow.
3. The conversation prompt provides issue-specific objectives.
4. Existing repository documentation remains the source of truth for architecture and requirements.

If a conflict is detected, stop and report it before making changes.

## Operating Rules

- Work only on the assigned GitHub issue.
- Never expand issue scope.
- Read documents according to DOCUMENT_RESPONSIBILITY_MATRIX.md.
- Produce an implementation plan before writing code unless the issue is documentation-only.
- Never commit or create a PR without explicit approval.

## Governance Rule

Repository governance documents are the primary source of workflow instructions.

Conversation prompts should remain concise and issue-specific.

If a conversation prompt duplicates repository workflow, follow the repository documentation and treat the prompt as a request to execute that documented workflow rather than redefining it.

## Progress Reporting

Report progress after each major phase:

- Repository verification
- Documentation loading
- Planning
- Implementation
- Validation
- Documentation updates
- Commit preparation
- PR preparation

If any tool command:

- requires approval,
- fails,
- or runs longer than 90 seconds,

stop immediately and report:

- the exact command,
- why it is running,
- current state,
- any proposed remediation.

Do not continue until the situation is acknowledged.

# IMPLEMENTATION_ROADMAP.md

> **Document Purpose**
>
> This document defines the official implementation roadmap for the Cryptocurrency Price API project.
>
> It provides the execution strategy, development phases, engineering milestones, implementation order, completion criteria, and project governance required to deliver the application.
>
> This document intentionally does **not** define project requirements or architecture. Those responsibilities belong to `PROJECT_SPECIFICATIONS.md`.
>
> During implementation this document serves as the authoritative project execution guide.

---

# Table of Contents

1. Purpose
2. Roadmap Philosophy
3. Engineering Workflow
4. Development Lifecycle
5. Phase Overview
6. Phase 1 – Repository Foundation
7. Phase 2 – Domain Design
8. Phase 3 – External API Integration
9. Phase 4 – Business Services
10. Phase 5 – Background Processing
11. Phase 6 – REST API
12. Phase 7 – Testing
13. Phase 8 – Production Hardening
14. Phase Exit Criteria
15. Git Strategy
16. Documentation Strategy
17. Risk Management
18. Release Strategy

---

# 1. Purpose

The purpose of this roadmap is to ensure that implementation proceeds in a predictable, traceable, and repeatable manner.

The roadmap establishes:

- the order in which work will be completed;
- the deliverables expected from each phase;
- the engineering standards required before work may proceed to the next phase;
- the documentation updates required throughout development;
- the verification activities required before project completion.

This document is intended for developers contributing to the implementation of the project and should be consulted before beginning any development activity.

---

# 2. Roadmap Philosophy

The project shall be developed incrementally.

Each implementation phase shall produce a fully working and verifiable state of the repository.

Implementation shall prioritise:

1. Stability
2. Correctness
3. Maintainability
4. Testability
5. Readability
6. Performance

New functionality shall never compromise the integrity of previously completed work.

Development shall favour small, reviewable increments over large feature branches.

Every completed phase should leave the repository in a releasable condition.

---

# 3. Engineering Workflow

Every feature implemented during this project shall follow the same engineering lifecycle.

```
Review Specification

↓

Understand Requirements

↓

Review Existing Architecture

↓

Design Solution

↓

Identify Risks

↓

Implement

↓

Write Automated Tests

↓

Execute Test Suite

↓

Perform Code Review

↓

Refactor

↓

Update Documentation

↓

Verify RTM Compliance

↓

Commit Changes

↓

Proceed to Next Task
```

This workflow shall be followed regardless of implementation complexity.

No implementation task shall bypass testing or documentation.

---

# 4. Development Lifecycle

Each phase follows the same structured lifecycle.

## Stage 1 – Planning

Before implementation begins:

- review project requirements;
- identify dependencies;
- confirm acceptance criteria;
- identify documentation updates;
- identify required automated tests.

No implementation work shall begin until the scope of the task is fully understood.

---

## Stage 2 – Implementation

Implementation should:

- follow Rails conventions;
- remain consistent with project architecture;
- minimise complexity;
- avoid unnecessary abstraction;
- produce readable code.

Code should prioritise maintainability over brevity.

---

## Stage 3 – Verification

Every implementation shall be verified using automated testing.

Verification includes:

- unit testing;
- integration testing where appropriate;
- manual verification when required;
- static analysis;
- code review.

No implementation is considered complete until verification succeeds.

---

## Stage 4 – Documentation

Documentation shall be updated immediately after implementation.

Documentation updates include:

- architectural changes;
- implementation decisions;
- public API changes;
- database modifications;
- operational behaviour;
- testing procedures.

Documentation is considered part of the implementation.

---

## Stage 5 – Completion

A development task is complete only when:

- implementation satisfies the specification;
- automated tests pass;
- documentation has been updated;
- static analysis passes;
- repository remains deployable.

---

# 5. Phase Overview

The project shall be completed in the following sequence.

| Phase | Name                     | Primary Objective                                           |
| ----- | ------------------------ | ----------------------------------------------------------- |
| 1     | Repository Foundation    | Establish project infrastructure and engineering standards  |
| 2     | Domain Design            | Create the application's domain model and persistence layer |
| 3     | External API Integration | Implement communication with CoinGecko                      |
| 4     | Business Services        | Implement business rules and caching strategy               |
| 5     | Background Processing    | Automate price refresh operations                           |
| 6     | REST API                 | Expose application functionality                            |
| 7     | Testing                  | Achieve production-quality reliability                      |
| 8     | Production Hardening     | Prepare the application for production deployment           |
| 9     | Final Verification       | Validate project readiness for interview submission         |

Development shall proceed sequentially unless a documented engineering decision requires otherwise.

---

# 6. Phase Dependencies

Each phase depends on the successful completion of previous phases.

```
Repository Foundation
        │
        ▼
Domain Design
        │
        ▼
External API Integration
        │
        ▼
Business Services
        │
        ▼
Background Processing
        │
        ▼
REST API
        │
        ▼
Testing
        │
        ▼
Production Hardening
        │
        ▼
Final Verification
```

No phase should begin until all exit criteria from the previous phase have been satisfied.

---

# 7. Milestone Governance

At the conclusion of every implementation phase the following activities shall be completed.

## Engineering Review

Verify that implementation satisfies all related functional and non-functional requirements.

---

## Quality Review

Confirm:

- coding standards;
- project conventions;
- architectural consistency;
- maintainability.

---

## Testing Review

Confirm:

- all new automated tests pass;
- no existing tests regress;
- coverage remains above the defined threshold.

---

## Documentation Review

Verify all affected documentation has been updated.

Documentation shall never lag behind implementation.

---

## Repository Review

Ensure:

- repository builds successfully;
- application starts correctly;
- no temporary code remains;
- no debugging artefacts remain;
- repository is ready for the next development phase.

---

## Phase Approval

Only after all review activities have completed successfully may the next implementation phase begin.

Every approved phase shall conclude with a Git commit representing a stable repository state.

# 8. Phase 1 – Repository Foundation

## Phase Objective

The objective of this phase is to establish a production-ready engineering foundation before any business functionality is implemented.

At the conclusion of this phase the repository shall:

- build successfully;
- follow established engineering standards;
- contain the agreed project structure;
- support local development;
- support automated testing;
- support continuous integration;
- contain the initial project documentation.

No application-specific business logic shall be introduced during this phase.

---

## Business Value

Although no interview functionality is implemented during this phase, it establishes the engineering practices that will govern the remainder of the project.

The quality of every subsequent implementation phase depends upon the successful completion of this phase.

---

## Deliverables

### Repository

- Initialize Git repository.
- Configure default branch.
- Configure repository ignore rules.
- Create project directory structure.

---

### Rails

- Generate Rails API application.
- Configure PostgreSQL.
- Configure environments.
- Verify local execution.

---

### Development Environment

Configure:

- Ruby version
- Bundler
- Database connectivity
- Environment variables
- Rails credentials

---

### Quality Tooling

Configure:

- RSpec
- RuboCop
- Brakeman
- SimpleCov

Each tool shall execute successfully before the phase is considered complete.

---

### Containerization

Create:

- Dockerfile
- docker-compose.yml
- development container configuration

The application shall be capable of running inside Docker.

---

### Continuous Integration

Create the initial GitHub Actions workflow.

The pipeline shall verify:

- bundle install
- RuboCop
- Brakeman
- RSpec

Future enhancements may extend the pipeline, but these quality gates shall exist from the beginning.

---

### Documentation

Create the documentation structure defined within PROJECT_SPECIFICATIONS.md.

Only foundational documentation shall be created during this phase.

Implementation-specific documentation shall be completed during later phases.

---

## Phase Dependencies

None.

This is the first implementation phase.

---

## Related Requirements

NFR-001

NFR-007

NFR-008

NFR-009

NFR-010

NFR-011

NFR-014

---

## Acceptance Criteria

The phase shall be accepted only when:

- Rails application starts successfully.
- PostgreSQL connects successfully.
- Docker build succeeds.
- Docker Compose starts successfully.
- GitHub Actions execute successfully.
- RuboCop passes.
- Brakeman passes.
- RSpec executes successfully.
- Documentation exists.
- Repository committed.

---

## Required Documentation Updates

The following documents shall be updated.

README.md

PROJECT_STRUCTURE.md

JUNIOR_DEVELOPER_GUIDE.md

ENGINEERING_JOURNAL.md

---

## Required Testing

Verification shall include:

- Application boots.
- Database connectivity.
- Docker execution.
- CI pipeline.
- Static analysis.

No business tests are expected during this phase.

---

## Risks

Potential implementation risks include:

- Ruby version mismatch.
- PostgreSQL configuration.
- Docker networking.
- Dependency incompatibilities.
- Platform-specific issues.

Each issue shall be resolved before proceeding.

---

## Git Milestone

Recommended commit message

```
chore: establish engineering foundation
```

---

# 9. Phase 2 – Domain Design

## Phase Objective

Create the application's domain model and persistence layer.

The goal of this phase is to establish the core business entities that support the remainder of the project.

No external API communication shall occur during this phase.

---

## Business Value

The persistence layer forms the foundation upon which caching, business services, background processing, and API endpoints will depend.

A stable domain model significantly reduces future implementation complexity.

---

## Deliverables

### Domain Model

Create:

CryptoPrice

Responsibilities:

- represent stored cryptocurrency prices;
- validate persisted data;
- encapsulate domain state.

---

### Database

Create:

- migrations;
- indexes;
- constraints;
- schema documentation.

The schema should support efficient lookup by cryptocurrency symbol.

---

### Repository Layer

Implement the persistence abstraction.

Responsibilities include:

- retrieving prices;
- updating prices;
- creating new records;
- isolating ActiveRecord queries.

Business logic shall not exist within the repository.

---

### Cache Layer

Create a dedicated cache abstraction.

Responsibilities:

- read cached values;
- write cached values;
- invalidate cache entries.

Controllers and services shall interact with the cache abstraction rather than Rails.cache directly.

---

## Phase Dependencies

Requires successful completion of Phase 1.

---

## Related Requirements

FR-005

NFR-001

NFR-005

---

## Acceptance Criteria

- Database schema finalized.
- Migration executes successfully.
- Repository implemented.
- Cache abstraction implemented.
- Model validations complete.
- Database indexes verified.
- Documentation updated.
- Tests passing.

---

## Required Documentation Updates

DATABASE.md

ARCHITECTURE.md

ENGINEERING_JOURNAL.md

JUNIOR_DEVELOPER_GUIDE.md

---

## Required Testing

Model Specs

Repository Specs

Cache Specs

Validation Tests

Migration Verification

---

## Risks

Potential implementation risks include:

- over-engineering the domain;
- leaking ActiveRecord into services;
- tightly coupling cache implementation;
- missing database indexes.

Implementation should remain intentionally simple while preserving extensibility.

---

## Git Milestone

Recommended commit message

```
feat: implement domain model and persistence layer
```

---

# 10. Phase 3 – External API Integration

## Phase Objective

Implement reliable communication with the CoinGecko API.

This phase establishes all interaction with external systems.

No controller or business service shall communicate directly with CoinGecko.

---

## Business Value

External communication is isolated to a dedicated client implementation.

Future provider changes should require modification only within the client layer.

---

## Deliverables

### CoinGecko Client

Implement a dedicated client responsible for:

- constructing requests;
- authenticating requests;
- parsing responses;
- validating responses;
- raising predictable exceptions.

---

### HTTP Configuration

Configure:

- request timeout;
- connection timeout;
- retry behaviour;
- headers;
- API key management.

Configuration shall remain environment-specific.

---

### Response Validation

Validate:

- response status;
- JSON structure;
- required fields;
- numeric values;
- supported currencies.

Malformed responses shall never reach the service layer.

---

### Error Handling

Handle:

- network failures;
- HTTP failures;
- provider downtime;
- invalid JSON;
- unexpected response structures.

Failures shall be translated into application-specific exceptions.

---

### Logging

Log:

- provider name;
- request duration;
- response status;
- retry attempts;
- failures.

Sensitive information shall never be logged.

---

## Phase Dependencies

Requires successful completion of Phase 2.

---

## Related Requirements

FR-003

FR-007

---

## Acceptance Criteria

- Client successfully retrieves live prices.
- Invalid responses rejected.
- Timeouts handled.
- Retry strategy verified.
- Exceptions standardized.
- Logging verified.
- Tests passing.
- Documentation updated.

---

## Required Documentation Updates

ARCHITECTURE.md

API.md

ENGINEERING_JOURNAL.md

JUNIOR_DEVELOPER_GUIDE.md

---

## Required Testing

Client Specs

API Response Parsing

Timeout Handling

Retry Behaviour

Failure Scenarios

Malformed Response Tests

---

## Risks

Potential implementation risks include:

- provider API changes;
- undocumented response fields;
- network instability;
- excessive retries;
- poor timeout configuration.

Implementation should prioritise resilience over complexity.

---

## Git Milestone

Recommended commit message

```
feat: implement CoinGecko client integration
```

---

# Phase Review Checklist

The completion of Phases 1–3 shall be reviewed using the following checklist.

| Review Item                    | Status |
| ------------------------------ | ------ |
| Repository foundation complete | ☐      |
| Rails configuration verified   | ☐      |
| Docker operational             | ☐      |
| CI pipeline operational        | ☐      |
| Persistence layer implemented  | ☐      |
| Cache abstraction implemented  | ☐      |
| CoinGecko client implemented   | ☐      |
| Automated tests passing        | ☐      |
| Documentation synchronized     | ☐      |
| RTM updated                    | ☐      |
| Repository ready for Phase 4   | ☐      |

No work on the Business Services layer shall commence until every checklist item has been verified.

# 11. Phase 4 – Business Services

## Phase Objective

Implement the application's business logic layer.

This phase is responsible for transforming the persistence layer and external provider into a cohesive domain service capable of supporting the REST API.

Business rules shall be isolated from controllers, models, jobs, and repositories.

---

## Business Value

The Service Layer represents the application's core business capability.

It coordinates:

- cache management;
- repository access;
- provider communication;
- validation;
- fallback behaviour.

The service layer shall remain independent of HTTP concerns and database implementation details.

---

## Deliverables

### PriceQueryService

Responsibilities:

- retrieve cryptocurrency prices;
- prioritise cached values;
- retrieve persisted values when cache misses occur;
- provide a consistent response model.

---

### PriceRefreshService

Responsibilities:

- request current prices from CoinGecko;
- validate provider responses;
- persist updated values;
- refresh cache;
- handle provider failures gracefully.

---

### Cache Synchronisation

Ensure cache and database remain consistent after successful refresh operations.

---

### Graceful Degradation

When upstream failures occur:

- preserve existing cached data;
- preserve persisted data;
- prevent unnecessary application failures;
- expose predictable behaviour to API consumers.

---

## Phase Dependencies

Requires successful completion of:

- Phase 2
- Phase 3

---

## Related Requirements

FR-002

FR-005

FR-006

FR-007

---

## Acceptance Criteria

- Service layer implemented.
- Business rules isolated.
- Cache prioritised correctly.
- Fallback behaviour verified.
- Documentation updated.
- Tests passing.

---

## Required Documentation Updates

ARCHITECTURE.md

TESTING.md

ENGINEERING_JOURNAL.md

JUNIOR_DEVELOPER_GUIDE.md

---

## Required Testing

Service Specs

Caching Behaviour

Fallback Behaviour

Failure Scenarios

Business Rule Validation

---

## Git Milestone

Recommended commit message

```text
feat: implement business service layer
```

---

# 12. Phase 5 – Background Processing

## Phase Objective

Automate cryptocurrency price synchronisation.

Background processing shall become the exclusive mechanism responsible for refreshing application data.

The REST API shall never communicate directly with CoinGecko.

---

## Business Value

Separating scheduled refresh operations from API requests:

- improves performance;
- improves reliability;
- reduces provider load;
- enables graceful degradation.

---

## Deliverables

Create:

- PriceRefreshJob
- Scheduler configuration
- Logging
- Failure recovery

The scheduler shall execute every minute.

---

## Responsibilities

Each execution shall:

1. retrieve configured cryptocurrencies;
2. request latest prices;
3. validate responses;
4. persist data;
5. update cache;
6. record execution logs.

Failures shall never terminate future scheduled executions.

---

## Phase Dependencies

Requires completion of:

- Phase 4

---

## Related Requirements

FR-004

FR-005

FR-007

---

## Acceptance Criteria

- Scheduler operational.
- Job executes successfully.
- Cache updated.
- Database updated.
- Failures logged.
- Retry behaviour verified.
- Tests passing.

---

## Required Documentation

BACKGROUND_JOBS.md

ENGINEERING_JOURNAL.md

JUNIOR_DEVELOPER_GUIDE.md

---

## Required Testing

Job Specs

Scheduler Verification

Failure Recovery

Logging Verification

---

## Git Milestone

Recommended commit message

```text
feat: implement scheduled price refresh
```

---

# 13. Phase 6 – REST API

## Phase Objective

Expose the application's public interface.

The API shall provide a predictable, versionable interface for retrieving cryptocurrency prices.

Controllers shall remain orchestration components only.

---

## Deliverables

Implement:

GET /prices/:symbol

Responsibilities include:

- request validation;
- service invocation;
- response serialization;
- error handling;
- HTTP status mapping.

---

## Response Behaviour

Successful responses shall contain:

- symbol;
- price;
- currency;
- timestamp.

Failure responses shall:

- follow a consistent JSON format;
- include meaningful error messages;
- use appropriate HTTP status codes.

---

## Phase Dependencies

Requires:

- Phase 4
- Phase 5

---

## Related Requirements

FR-001

FR-002

FR-008

FR-009

---

## Acceptance Criteria

- Endpoint operational.
- Validation complete.
- Responses serialised correctly.
- Error handling verified.
- Tests passing.

---

## Required Documentation

API.md

TESTING.md

JUNIOR_DEVELOPER_GUIDE.md

---

## Required Testing

Request Specs

Response Validation

Error Responses

HTTP Status Verification

---

## Git Milestone

Recommended commit message

```text
feat: expose cryptocurrency price API
```

---

# 14. Phase 7 – Testing & Quality Assurance

## Phase Objective

Verify that the application satisfies all functional and non-functional requirements.

Testing shall validate behaviour rather than implementation details.

---

## Deliverables

Complete:

- Model Specs
- Repository Specs
- Client Specs
- Service Specs
- Job Specs
- Request Specs
- Cache Specs
- Fallback Specs

---

## Quality Objectives

Coverage target:

95% or greater.

Every production component shall have meaningful automated verification.

---

## Acceptance Criteria

- Entire suite passing.
- No flaky tests.
- Coverage threshold achieved.
- Static analysis passing.

---

## Required Documentation

TESTING.md

ENGINEERING_JOURNAL.md

---

## Git Milestone

Recommended commit message

```text
test: complete production test suite
```

---

# 15. Phase 8 – Production Hardening

## Phase Objective

Prepare the repository for production-quality delivery.

This phase focuses on operational excellence rather than feature development.

---

## Deliverables

Perform:

- code review;
- refactoring;
- security review;
- performance review;
- dependency review;
- documentation review.

No new features shall be introduced during this phase.

---

## Quality Verification

Confirm:

- RuboCop passes.
- Brakeman passes.
- Docker build succeeds.
- CI succeeds.
- Documentation complete.
- RTM complete.

---

## Required Documentation

Review every document within:

docs/

development/

---

## Acceptance Criteria

Repository considered production ready.

---

## Git Milestone

Recommended commit message

```text
chore: production hardening and repository review
```

---

# 16. Phase 9 – Final Verification & Interview Release

## Phase Objective

Produce the final interview-ready repository.

No implementation work shall occur during this phase.

Only verification and release preparation are permitted.

---

## Deliverables

Complete:

- Requirements Traceability Matrix
- Final documentation review
- Repository cleanup
- Release tag
- Final walkthrough

---

## Final Validation Checklist

Verify:

✓ Functional requirements complete

✓ Non-functional requirements complete

✓ Tests passing

✓ Documentation complete

✓ Docker operational

✓ CI operational

✓ Security review complete

✓ Repository reviewed

✓ Junior Developer Guide validated

✓ Engineering Journal complete

---

## Release Candidate

When every validation item succeeds, create:

Version 1.0

Interview Release

---

## Git Milestone

Recommended commit message

```text
release: interview submission v1.0
```

---

# 17. Risk Management Strategy

The following project risks shall be monitored throughout implementation.

## Technical Risks

- Provider API changes
- Dependency incompatibilities
- Framework updates
- Database migration issues
- Docker configuration issues

---

## Engineering Risks

- Architecture drift
- Over-engineering
- Documentation drift
- Incomplete test coverage
- Requirement omissions

---

## Mitigation Strategy

Each implementation phase shall conclude with:

- specification review;
- RTM verification;
- documentation review;
- automated testing;
- repository review.

---

# 18. Rollback Strategy

Should implementation introduce instability:

1. Stop feature development.
2. Revert to the previous stable commit.
3. Identify root cause.
4. Update Engineering Journal.
5. Re-implement.
6. Re-run full verification.

Repository stability shall always take precedence over implementation velocity.

---

# 19. Documentation Maintenance Strategy

Documentation shall evolve alongside implementation.

Whenever implementation changes:

- update architecture documentation;
- update testing documentation;
- update API documentation;
- update Junior Developer Guide;
- update Engineering Journal if architectural decisions change.

No implementation change shall leave documentation inconsistent.

---

# 20. Project Completion Criteria

The implementation roadmap shall be considered complete only when every phase satisfies its defined exit criteria.

The repository shall demonstrate:

- production-quality engineering;
- clean architecture;
- comprehensive documentation;
- high automated test coverage;
- operational readiness;
- maintainability;
- graceful degradation;
- interview readiness.

---

# 21. Success Metrics

The implementation shall be considered successful when:

- All Functional Requirements have been implemented.
- All Non-Functional Requirements have been verified.
- Every Requirements Traceability Matrix item is complete.
- Every automated test passes successfully.
- Coverage meets or exceeds the defined threshold.
- Static analysis reports no unresolved issues.
- Docker images build successfully.
- Continuous Integration passes consistently.
- Documentation accurately reflects the implementation.
- A junior developer can recreate the application solely by following the project documentation.
- The repository is suitable for presentation as a production-quality engineering project during technical interviews.

---

# Roadmap Approval

This roadmap defines the official implementation strategy for the Cryptocurrency Price API project.

All development work shall proceed in accordance with this roadmap.

Changes to implementation sequencing, engineering standards, or milestone definitions shall be documented before implementation continues.

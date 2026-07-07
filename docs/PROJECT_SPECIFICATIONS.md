# PROJECT_SPECIFICATIONS.md

> **Project Name:** Cryptocurrency Price API
>
> **Version:** 1.0
>
> **Status:** Approved requirements for a pre-implementation documentation-only repository
>
> **Document Owner:** Engineering
>
> **Purpose:** This document serves as the authoritative engineering specification for the Cryptocurrency Price API project. All implementation, testing, documentation, and architectural decisions must conform to this specification. If implementation differs from this document, the specification must be updated before the code.

---

## 1. Project Objective

Define and then build a production-quality Ruby on Rails API that periodically retrieves cryptocurrency prices from the CoinGecko API, stores the latest values, exposes a REST endpoint for retrieving prices, and continues serving the last known value if the external API becomes unavailable.

The project must satisfy the interview requirements while demonstrating senior-level backend engineering practices.

---

## 2. Problem Statement

Implement a REST API that:

- Retrieves cryptocurrency prices from CoinGecko.
- Stores the latest retrieved price.
- Refreshes prices automatically every minute.
- Returns the cached value to API consumers.
- Continues serving the most recently stored value if CoinGecko becomes unavailable.
- Includes comprehensive automated tests.

---

## 3. Primary Objectives

The completed repository must demonstrate:

- Clean Architecture
- Production-quality code
- Readable design
- High test coverage
- Proper documentation
- Enterprise engineering standards
- Maintainability
- Extensibility

---

## 4. Functional Requirements

### FR-001

Expose

GET /prices/:symbol

Example

GET /prices/btc

---

### FR-002

Return

```json
{
  "symbol": "btc",
  "price": 109283.12,
  "currency": "usd",
  "last_updated_at": "2026-07-07T10:35:00Z"
}
```

---

### FR-003

Retrieve pricing information from CoinGecko.

---

### FR-004

Refresh stored prices every minute.

---

### FR-005

Persist retrieved prices.

---

### FR-006

Always serve the most recently available price.

---

### FR-007

If CoinGecko fails:

- Do not return HTTP 500 because of upstream failures.
- Continue serving the most recent stored value.
- Log the failure.
- Retry during the next scheduled refresh.

---

### FR-008

Return appropriate HTTP status codes.

---

### FR-009

Return consistent JSON error responses.

---

## 5. Non-Functional Requirements

The application shall be:

- Deterministic
- Maintainable
- Testable
- Extensible
- Secure
- Well documented
- Containerized
- CI compatible

---

## 6. Architecture Principles

The project shall follow:

- MVC
- Service Objects
- Repository Pattern
- Dependency Injection where appropriate
- Single Responsibility Principle
- Open/Closed Principle
- Explicit Dependencies
- Composition over inheritance

Business logic must never exist inside controllers.

External API communication must never exist inside controllers.

Database logic must never exist inside controllers.

---

## 7. Application Layers

Request

↓

Controller

↓

Service

↓

Repository

↓

Database

External communication

↓

Client

↓

CoinGecko

Caching

↓

Cache Service

---

## 8. Technology Stack

Accepted target technologies:

- Ruby
- Rails API
- PostgreSQL
- ActiveJob abstraction
- RSpec
- Docker
- GitHub Actions
- RuboCop
- Brakeman
- SimpleCov
- Faraday (HTTP client)

Proposed or deferred implementation decisions:

- Concrete ActiveJob adapter
- Scheduler implementation
- Cache store backend
- Redis usage, if any
- Background worker process layout

These proposed or deferred decisions must be resolved in the relevant implementation phase before configuration or infrastructure is created.

---

## 9. Data Model

Primary entity

CryptoPrice

Attributes

- symbol
- price
- currency
- provider
- fetched_at
- created_at
- updated_at

Indexes

- composite unique index on symbol, currency, and provider for current-price identity
- supporting lookup index aligned with symbol, currency, and provider queries when needed

A symbol-only lookup may be added only as a non-unique supporting index if query evidence requires it; it must not replace or conflict with composite uniqueness on symbol, currency, and provider.

Validations

- symbol required
- price required
- currency required
- provider required

---

## 10. Caching Strategy

API requests must never call CoinGecko directly.

Reads should occur in the following order:

1. Rails Cache
2. Database
3. Return response

Background jobs are responsible for updating:

- Database
- Cache

---

## 11. Background Processing

A scheduled job shall execute every minute.

Responsibilities

- Fetch latest prices
- Validate response
- Persist data
- Update cache
- Log failures
- Never terminate the scheduler because of API failures

---

## 12. Error Handling

Expected failures include:

- API timeout
- Network failure
- Invalid response
- Missing cryptocurrency
- Invalid request
- Database validation failure

Each failure must produce:

- Structured logs
- Predictable API behaviour
- Appropriate HTTP status

---

## 13. Logging

Application logs shall include:

- Request ID
- Symbol
- Provider
- Execution time
- Error details

Sensitive information shall never be logged.

---

## 14. Security

Secrets shall never be committed.

API keys shall be stored using environment variables or Rails credentials.

No sensitive configuration may exist in source control.

---

## 15. Performance Requirements

The application should:

- Minimize database queries.
- Avoid unnecessary API requests.
- Use indexed lookups.
- Serve cached responses whenever possible.

---

## 16. Testing Requirements

The project shall include:

Model Specs

Service Specs

Repository Specs

Client Specs

Job Specs

Request Specs

Caching Specs

Fallback Specs

Coverage target

95%+

Every production class must have corresponding automated tests.

---

## 17. Code Quality Standards

The repository must pass:

- RuboCop
- Brakeman
- RSpec
- SimpleCov threshold

No warnings should remain unresolved.

---

## 18. Documentation Requirements

The repository shall contain:

README.md

API.md

ARCHITECTURE.md

TESTING.md

ENGINEERING_JOURNAL.md

JUNIOR_DEVELOPER_GUIDE.md

Each document must remain synchronized with implementation.

---

## 19. Repository Structure

The repository shall maintain a clear separation between:

- Controllers
- Models
- Services
- Clients
- Repositories
- Jobs
- Documentation
- Tests

No business logic shall exist outside the defined application layers.

---

## 20. Definition of Done

The project shall be considered complete only when:

✓ All interview requirements are implemented.

✓ All automated tests pass.

✓ Coverage exceeds the defined threshold.

✓ Docker build succeeds.

✓ GitHub Actions pass.

✓ Documentation is complete.

✓ Static analysis passes.

✓ The application demonstrates graceful degradation during upstream failures.

✓ The project can be recreated by following the Junior Developer Guide.

---

## 21. Out of Scope

The following features are intentionally excluded:

- Authentication
- User management
- Cryptocurrency trading
- Historical charts
- WebSockets
- Rate limiting
- Multi-provider aggregation

These may be documented as future enhancements but shall not be implemented unless explicitly required.

---

## 22. Engineering Rules

During implementation:

1. No feature is complete without tests.
2. No feature is complete without documentation.
3. No code is merged without review.
4. No TODO comments shall remain in production code.
5. Prefer readability over cleverness.
6. Follow Rails conventions unless there is a documented reason not to.
7. Every architectural decision must be recorded in the Engineering Journal.
8. This document is the single source of truth for the project. If implementation and specification differ, the specification must be updated before implementation proceeds.

---

## Appendix A – Requirements Traceability Matrix (RTM)

### Purpose

This Requirements Traceability Matrix (RTM) establishes a direct relationship
between the interview requirements, implementation components, automated tests,
documentation, and final verification.

No requirement shall be considered complete until every associated
implementation, test, and documentation item has been completed.

---

| ID     | Requirement                               | Implementation                           | Test Coverage                 | Documentation          | Status |
| ------ | ----------------------------------------- | ---------------------------------------- | ----------------------------- | ---------------------- | ------ |
| FR-001 | GET /prices/:symbol endpoint              | PricesController                         | Request Specs                 | API.md                 | ☐      |
| FR-002 | Return latest cached cryptocurrency price | PriceQueryService, PriceCache            | Service Specs, Cache Specs    | ARCHITECTURE.md        | ☐      |
| FR-003 | Retrieve prices from CoinGecko            | CoinGeckoClient                          | Client Specs                  | ARCHITECTURE.md        | ☐      |
| FR-004 | Refresh prices every minute               | PriceRefreshJob, Scheduler               | Job Specs                     | BACKGROUND_JOBS.md     | ☐      |
| FR-005 | Persist retrieved prices                  | CryptoPriceRepository, CryptoPrice Model | Repository Specs, Model Specs | DATABASE.md            | ☐      |
| FR-006 | Return last stored value                  | PriceQueryService                        | Service Specs                 | ARCHITECTURE.md        | ☐      |
| FR-007 | Continue serving prices when API fails    | RefreshService Fallback Logic            | Fallback Specs                | ENGINEERING_JOURNAL.md | ☐      |
| FR-008 | Proper HTTP status codes                  | Controller Error Handling                | Request Specs                 | API.md                 | ☐      |
| FR-009 | Consistent JSON error responses           | ErrorSerializer                          | Request Specs                 | API.md                 | ☐      |

---

### Non-Functional Requirement Traceability

| ID      | Requirement                            | Verification Method  | Status |
| ------- | -------------------------------------- | -------------------- | ------ |
| NFR-001 | Clean Architecture                     | Architecture Review  | ☐      |
| NFR-002 | SOLID Principles                       | Code Review          | ☐      |
| NFR-003 | Thin Controllers                       | Code Review          | ☐      |
| NFR-004 | Service Layer Separation               | Code Review          | ☐      |
| NFR-005 | Repository Pattern                     | Code Review          | ☐      |
| NFR-006 | Dependency Injection where appropriate | Code Review          | ☐      |
| NFR-007 | Dockerized Application                 | Docker Build         | ☐      |
| NFR-008 | GitHub Actions Pipeline                | CI Build             | ☐      |
| NFR-009 | RuboCop Passes                         | Static Analysis      | ☐      |
| NFR-010 | Brakeman Passes                        | Security Scan        | ☐      |
| NFR-011 | SimpleCov Coverage ≥95%                | Automated Test Suite | ☐      |
| NFR-012 | Production Logging                     | Manual Verification  | ☐      |
| NFR-013 | Environment-based Configuration        | Code Review          | ☐      |
| NFR-014 | Secure Secret Management               | Code Review          | ☐      |
| NFR-015 | Complete Documentation                 | Documentation Review | ☐      |

---

### Documentation Traceability

| Document                  | Purpose                                  | Completion |
| ------------------------- | ---------------------------------------- | ---------- |
| README.md                 | Project overview and quick start         | ☐          |
| API.md                    | REST API specification                   | ☐          |
| ARCHITECTURE.md           | System architecture and request flow     | ☐          |
| DATABASE.md               | Database design and persistence strategy | ☐          |
| BACKGROUND_JOBS.md        | Scheduled job implementation             | ☐          |
| TESTING.md                | Testing strategy and execution           | ☐          |
| ENGINEERING_JOURNAL.md    | Engineering decisions and trade-offs     | ☐          |
| JUNIOR_DEVELOPER_GUIDE.md | Complete project recreation guide        | ☐          |

---

### Automated Test Matrix

| Component             | Unit | Integration | Request | Status |
| --------------------- | ---- | ----------- | ------- | ------ |
| CryptoPrice Model     | ☐    | N/A         | N/A     | ☐      |
| CoinGeckoClient       | ☑    | ☐           | N/A     | ☐      |
| PriceCache            | ☑    | ☐           | N/A     | ☐      |
| CryptoPriceRepository | ☑    | ☐           | N/A     | ☐      |
| PriceQueryService     | ☑    | ☐           | N/A     | ☐      |
| PriceRefreshService   | ☑    | ☐           | N/A     | ☐      |
| PriceRefreshJob       | ☑    | ☐           | N/A     | ☐      |
| PricesController      | N/A  | ☐           | ☑       | ☐      |

---

### Production Readiness Checklist

| Item                               | Complete |
| ---------------------------------- | -------- |
| Docker Build Successful            | ☐        |
| Docker Compose Starts Successfully | ☐        |
| GitHub Actions Passing             | ☐        |
| All Tests Passing                  | ☐        |
| Coverage ≥95%                      | ☐        |
| RuboCop Passing                    | ☐        |
| Brakeman Passing                   | ☐        |
| No TODO Comments Remaining         | ☐        |
| API Documentation Complete         | ☐        |
| Junior Developer Guide Complete    | ☐        |
| Engineering Journal Complete       | ☐        |
| Final Repository Review Complete   | ☐        |

---

### Final Acceptance Criteria

The project shall not be considered complete until:

- Every Functional Requirement is marked complete.
- Every Non-Functional Requirement is verified.
- Every automated test passes.
- Documentation has been reviewed.
- CI pipeline passes.
- Docker image builds successfully.
- The application demonstrates graceful degradation during CoinGecko failures.
- A junior developer can recreate the project by following the documentation without external assistance.

---

## Appendix B – Implementation Phases & Milestones

### Purpose

This appendix defines the official implementation roadmap for the project.

Development shall proceed sequentially through each phase.

A phase shall not be considered complete until:

- All implementation tasks are complete.
- All automated tests pass.
- Documentation has been updated.
- Static analysis passes.
- The phase review has been completed.
- A Git commit has been created.

No implementation work from a future phase should begin until the current phase satisfies its exit criteria.

---

### Phase 1 — Project Foundation

#### Objective

Create a production-ready Rails API project and establish the engineering standards that will govern the repository.

##### Deliverables

- Initialize Git repository
- Create Rails API application
- Configure PostgreSQL
- Configure Docker
- Configure Docker Compose
- Configure RSpec
- Configure RuboCop
- Configure Brakeman
- Configure SimpleCov
- Configure GitHub Actions
- Configure environment variables
- Configure project structure
- Create initial documentation

##### Related Requirements

- NFR-001
- NFR-007
- NFR-008
- NFR-009
- NFR-010
- NFR-011
- NFR-014

##### Documentation Updates

- README.md
- JUNIOR_DEVELOPER_GUIDE.md

##### Exit Criteria

- Project boots successfully
- Database connection succeeds
- Test suite executes
- Docker builds
- CI executes
- Repository committed

---

### Phase 2 — Domain Layer

#### Objective

Establish the application's core business entities.

##### Deliverables

- CryptoPrice model
- Database migration
- Model validations
- Database indexes
- Repository layer
- Cache abstraction

##### Related Requirements

- FR-005
- NFR-001
- NFR-005

##### Documentation Updates

- DATABASE.md
- ARCHITECTURE.md
- ENGINEERING_JOURNAL.md

##### Required Tests

- Model Specs
- Repository Specs
- Cache Specs

##### Exit Criteria

- Persistence complete
- Tests passing
- Documentation updated

---

### Phase 3 — External API Integration

#### Objective

Implement reliable communication with CoinGecko.

##### Deliverables

- CoinGecko client
- HTTP configuration
- Timeouts
- Error handling
- Response validation
- Logging

##### Related Requirements

- FR-003
- FR-007

##### Documentation Updates

- ARCHITECTURE.md
- ENGINEERING_JOURNAL.md

##### Required Tests

- Client Specs
- Failure Scenarios
- Invalid Response Tests

##### Exit Criteria

- API communication verified
- Failure handling verified
- Tests passing

---

### Phase 4 — Business Logic

#### Objective

Implement the application's service layer.

##### Deliverables

- PriceQueryService
- PriceRefreshService
- Cache management
- Database integration
- Fallback logic

##### Related Requirements

- FR-002
- FR-005
- FR-006
- FR-007

##### Documentation Updates

- ARCHITECTURE.md
- ENGINEERING_JOURNAL.md

##### Required Tests

- Service Specs
- Cache Specs
- Fallback Specs

##### Exit Criteria

- Services complete
- Cache verified
- Fallback verified

---

### Phase 5 — Background Processing

#### Objective

Automate price retrieval.

##### Deliverables

- PriceRefreshJob
- Scheduler configuration
- Logging
- Retry strategy

##### Related Requirements

- FR-004
- FR-005
- FR-007

##### Documentation Updates

- BACKGROUND_JOBS.md
- ENGINEERING_JOURNAL.md

##### Required Tests

- Job Specs
- Scheduler Tests

##### Exit Criteria

- Job executes successfully
- Scheduled execution verified
- Failure recovery verified

---

### Phase 6 — REST API

#### Objective

Expose the public API.

##### Deliverables

- PricesController
- Endpoint routing
- JSON serialization
- Error responses
- HTTP status handling

##### Related Requirements

- FR-001
- FR-002
- FR-008
- FR-009

##### Documentation Updates

- API.md

##### Required Tests

- Request Specs
- Controller Specs

##### Exit Criteria

- Endpoint operational
- Responses validated
- Error handling verified

---

### Phase 7 — Testing & Quality Assurance

#### Objective

Achieve production-quality reliability.

##### Deliverables

- Complete unit testing
- Integration testing
- Request testing
- Coverage reporting

##### Related Requirements

- NFR-011

##### Documentation Updates

- TESTING.md

##### Exit Criteria

- All tests passing
- Coverage ≥95%
- No failing scenarios

---

### Phase 8 — Production Hardening

#### Objective

Prepare the application for production deployment.

##### Deliverables

- Logging improvements
- Performance review
- Security review
- Documentation review
- Static analysis
- Final refactoring

##### Related Requirements

- NFR-009
- NFR-010
- NFR-012
- NFR-013
- NFR-014
- NFR-015

##### Documentation Updates

- All project documentation

##### Exit Criteria

- RuboCop passes
- Brakeman passes
- Documentation complete
- Repository production ready

---

### Phase 9 — Final Verification

#### Objective

Verify that every project requirement has been satisfied.

##### Deliverables

- Requirements Traceability Matrix completed
- Manual verification
- Final code review
- Documentation review
- Repository cleanup

##### Verification Checklist

□ Every Functional Requirement completed

□ Every Non-Functional Requirement completed

□ Every automated test passing

□ Docker build successful

□ CI pipeline passing

□ No TODO comments

□ No dead code

□ No lint violations

□ Documentation complete

□ Junior Developer Guide validated

□ Engineering Journal complete

□ Repository tagged as Version 1.0

##### Exit Criteria

Project approved for interview submission.

---

### Git Milestone Strategy

Every phase shall conclude with a Git commit.

Recommended commit sequence:

```
Phase 1: Initial Production Foundation

Phase 2: Domain Layer Complete

Phase 3: CoinGecko Integration Complete

Phase 4: Business Services Complete

Phase 5: Background Processing Complete

Phase 6: REST API Complete

Phase 7: Production Test Suite Complete

Phase 8: Production Hardening Complete

Phase 9: Interview Release v1.0
```

---

### Development Workflow

Every feature implemented during this project shall follow the same engineering lifecycle.

```
Understand Requirement

↓

Review Specification

↓

Design Solution

↓

Implement Feature

↓

Write Tests

↓

Execute Test Suite

↓

Refactor

↓

Update Documentation

↓

Review Against RTM

↓

Commit Changes

↓

Proceed to Next Feature
```

---

### Project Completion Criteria

The project is considered complete only when:

✓ Every implementation phase has been completed.

✓ Every milestone has been reviewed.

✓ Every RTM item is marked complete.

✓ Every automated test passes.

✓ Coverage exceeds the defined threshold.

✓ Static analysis passes without warnings.

✓ Documentation is complete and internally consistent.

✓ A junior developer can successfully recreate the project using only the provided documentation.

✓ The repository is suitable for submission as a production-quality interview project.

---

## Document Control

### Document Information

| Property       | Value                         |
| -------------- | ----------------------------- |
| Document Name  | PROJECT_SPECIFICATIONS.md     |
| Project        | Cryptocurrency Price API      |
| Document Type  | Engineering Specification     |
| Version        | 1.0.0                         |
| Status         | Approved for Implementation   |
| Owner          | Engineering                   |
| Last Updated   | 2026-07-07                    |
| Repository     | crypto-price-api              |
| Classification | Internal Engineering Document |

---

## Version History

| Version | Date       | Author      | Description                                            |
| ------- | ---------- | ----------- | ------------------------------------------------------ |
| 0.1     | 2026-07-07 | Engineering | Initial draft                                          |
| 0.5     | 2026-07-07 | Engineering | Added architecture, requirements and testing standards |
| 0.8     | 2026-07-07 | Engineering | Added Requirements Traceability Matrix                 |
| 0.9     | 2026-07-07 | Engineering | Added Implementation Phases & Milestones               |
| 1.0     | 2026-07-07 | Engineering | Approved implementation specification                  |

---

## Document Change Policy

This document is the authoritative engineering specification for the project.

Implementation shall always conform to this specification.

If implementation requires deviation from this document:

1. The proposed change shall be documented.
2. The engineering rationale shall be recorded.
3. The specification shall be updated.
4. Implementation may proceed only after the specification has been revised.

---

## Document Review Checklist

Prior to each implementation phase, verify that:

- Current phase objectives are clearly defined.
- Requirements Traceability Matrix has been reviewed.
- Documentation is synchronized.
- Acceptance criteria are understood.

---

## Engineering Principles

The following principles govern all implementation work.

### Simplicity

Choose the simplest solution that satisfies the requirements.

---

### Readability

Code is written for future engineers before computers.

---

### Maintainability

Every implementation should be easy to understand, modify, and extend.

---

### Reliability

Failures should be anticipated and handled gracefully.

---

### Testability

Every production component must be independently testable.

---

### Documentation

Documentation is considered production code.

Every architectural decision, implementation detail, and operational procedure shall be documented as the project evolves.

---

### Continuous Verification

Every completed phase shall conclude with:

- Successful build
- Passing tests
- Updated documentation
- Static analysis
- Git commit

No phase is complete until all five conditions are satisfied.

---

## Final Approval

This document defines the official engineering specification for the Cryptocurrency Price API project.

All implementation work shall reference this specification as the single source of truth throughout the lifecycle of the project.

---
name: architect
description: Design system architecture and component interfaces. Use for architectural decisions.
---

# System Architecture

Design scalable, maintainable system architectures.

## When to Use

- Major architectural decisions
- System design discussions
- Evaluating trade-offs
- Planning large refactors
- Reviewing system structure

## Design Process

1. **Understand** - Clarify requirements and constraints
2. **Identify** - Define components and boundaries
3. **Design** - Create architecture with trade-offs
4. **Validate** - Check against requirements
5. **Document** - Record decisions and rationale

## Architecture Patterns

### Layered Architecture

```
┌─────────────────────────────┐
│      Presentation Layer     │  UI, API endpoints
├─────────────────────────────┤
│       Business Layer        │  Domain logic, services
├─────────────────────────────┤
│      Persistence Layer      │  Repositories, DAOs
├─────────────────────────────┤
│        Data Layer           │  Database, cache
└─────────────────────────────┘
```

### Microservices

```
┌─────────┐  ┌─────────┐  ┌─────────┐
│ User    │  │ Order   │  │ Payment │
│ Service │  │ Service │  │ Service │
└────┬────┘  └────┬────┘  └────┬────┘
     │            │            │
     └────────────┼────────────┘
                  │
           ┌──────┴──────┐
           │ Message Bus │
           └─────────────┘
```

### Event-Driven

```
Producer → Event Bus → Consumer(s)
              │
              ├→ Service A
              ├→ Service B
              └→ Analytics
```

## Decision Framework

### Trade-off Analysis

| Aspect         | Option A | Option B   |
| -------------- | -------- | ---------- |
| Complexity     | Low      | High       |
| Scalability    | Limited  | Horizontal |
| Cost           | $        | $$$        |
| Time to market | Fast     | Slow       |
| Maintenance    | Easy     | Complex    |

### ADR Template

```markdown
# ADR-001: [Decision Title]

## Status

Accepted | Proposed | Deprecated

## Context

[Why we need to make this decision]

## Decision

[What we decided]

## Consequences

### Positive

- [Benefit 1]

### Negative

- [Trade-off 1]

### Risks

- [Risk 1]
```

## Key Principles

- **Separation of Concerns** - Each component has one responsibility
- **Loose Coupling** - Minimize dependencies between components
- **High Cohesion** - Related functionality grouped together
- **YAGNI** - Don't build for hypothetical requirements
- **Fail Fast** - Detect and report errors immediately

## Scalability Checklist

- [ ] Stateless services (session in Redis/DB)
- [ ] Horizontal scaling capability
- [ ] Database read replicas
- [ ] Caching layer (Redis, CDN)
- [ ] Async processing for heavy tasks
- [ ] Rate limiting and circuit breakers

## Examples

**Input:** "Design a notification system"
**Action:** Define channels, queue architecture, delivery guarantees, scaling strategy

**Input:** "Should we use microservices?"
**Action:** Analyze team size, complexity, scaling needs, recommend with trade-offs

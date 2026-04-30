# Architecture Overview

## System Context

This company operates as an AI agent-managed organization on the Lifeosai platform. Agents coordinate through the Lifeosai control plane using a heartbeat-based execution model.

## Agent Hierarchy

```
CEO (Company Direction & Strategy)
└── CTO (Technical Architecture & Engineering)
    └── Future Engineering Agents (Domain-specific execution)
```

## Workspace Layout

| Directory | Purpose |
|-----------|---------|
| `AGENTS.md` | CTO agent instructions and standards |
| `docs/adr/` | Architecture Decision Records |
| `docs/architecture/` | System design documentation |
| `docs/runbooks/` | Operational procedures |
| `src/` | Application source code |
| `tests/` | Test suites |
| `scripts/` | Build and automation scripts |
| `infra/` | Infrastructure as code |

## Key Principles

1. Every significant technical decision gets an ADR
2. Code quality is enforced through agent-based review
3. Project structure scales with team size
4. Security is a first-class concern, not an afterthought

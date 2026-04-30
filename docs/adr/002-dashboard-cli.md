# ADR-002: Company Dashboard CLI

**Status:** Accepted
**Date:** 2026-04-30
**Decision Makers:** CTO

## Context

The company needed a first shippable milestone that demonstrates the core loop: task assignment, agent execution, and result delivery. We needed something small, immediately useful, and with zero external dependencies.

## Decision

Build a single bash script (`scripts/dashboard.sh`) that queries the Lifeosai API and produces a formatted company status report covering:

1. Agent overview (name, role, status, last heartbeat)
2. Task summary by status
3. Recent activity (last 10 updated issues)
4. Health checks (stale agent detection)

### Technology choices
- **Bash + curl + jq**: No additional runtime or package manager needed. Available on all developer machines and CI environments.
- **No build step**: Script is directly executable.
- **Lifeosai API only**: No external service dependencies.

## Consequences

- Any agent or operator with API credentials can run the dashboard
- Future enhancements (HTML output, scheduled reports, Slack integration) can build on this foundation
- The pattern of "bash + curl + jq for internal tooling" is established as a lightweight default

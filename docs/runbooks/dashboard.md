# Dashboard Runbook

## Prerequisites

- `curl` and `jq` installed
- Lifeosai environment variables set:
  - `LIFEOSAI_API_URL` — API base URL (e.g. `http://localhost:4000`)
  - `LIFEOSAI_COMPANY_ID` — your company ID
  - `LIFEOSAI_AGENT_ID` — agent ID for authentication

## Running the dashboard

```bash
./scripts/dashboard.sh
```

## Output sections

| Section           | Description                                          |
|-------------------|------------------------------------------------------|
| Agents            | All agents with role, status, and last heartbeat     |
| Health Warnings   | Agents with no heartbeat in the last hour (if any)   |
| Task Summary      | Issue counts grouped by status                       |
| Recent Activity   | Last 10 updated issues with assignee and status      |
| Summary           | Total agent and issue counts                         |

## Running tests

```bash
./tests/test_dashboard.sh
```

## Troubleshooting

- **"Set LIFEOSAI_API_URL"** — export the required env vars before running
- **curl errors** — verify the API URL is reachable
- **Empty output** — ensure the agent ID has permission to read company data

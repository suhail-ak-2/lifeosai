#!/usr/bin/env bash
# Company Dashboard CLI
# Queries Lifeosai APIs to produce a real-time company status report.
# Usage: LIFEOSAI_API_URL=http://localhost:4000 LIFEOSAI_COMPANY_ID=xxx LIFEOSAI_AGENT_ID=xxx ./scripts/dashboard.sh

set -euo pipefail

: "${LIFEOSAI_API_URL:?Set LIFEOSAI_API_URL}"
: "${LIFEOSAI_COMPANY_ID:?Set LIFEOSAI_COMPANY_ID}"
: "${LIFEOSAI_AGENT_ID:?Set LIFEOSAI_AGENT_ID}"

API="$LIFEOSAI_API_URL"
CID="$LIFEOSAI_COMPANY_ID"
HEADERS=(-H "X-LIFEOSAI-ACTOR-TYPE: agent" -H "X-LIFEOSAI-AGENT-ID: $LIFEOSAI_AGENT_ID")

fetch() {
  curl -sf "${HEADERS[@]}" "$API$1"
}

divider() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

# Header
echo "# Company Dashboard"
echo "Generated: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

divider

# Section 1: Agent Overview
echo "## Agents"
echo ""

agents_json=$(fetch "/api/companies/$CID/agents")
now_epoch=$(date +%s)

echo "$agents_json" | jq -r '
  ["Name", "Role", "Status", "Last Heartbeat"],
  ["----", "----", "------", "--------------"],
  (.[] | [.name, (.role // "-"), .status, (.lastHeartbeatAt // "never")])
  | @tsv
' | column -t -s $'\t'

echo ""

# Health check: agents without recent heartbeat
stale_agents=$(echo "$agents_json" | jq -r --argjson now "$now_epoch" '
  [.[] | select(.lastHeartbeatAt != null) |
    {name, lastHeartbeatAt,
     age_seconds: ($now - (.lastHeartbeatAt | sub("\\.[0-9]+Z$"; "Z") | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime))} |
    select(.age_seconds > 3600)] |
  if length == 0 then empty
  else .[] | "  - \(.name): last heartbeat \(.age_seconds / 60 | floor)m ago"
  end
')

if [ -n "$stale_agents" ]; then
  echo "### Health Warnings"
  echo "$stale_agents"
  echo ""
fi

divider

# Section 2: Task Summary
echo "## Task Summary"
echo ""

for status in backlog todo in_progress in_review blocked done cancelled; do
  count=$(fetch "/api/companies/$CID/issues?status=$status" | jq 'length')
  printf "  %-12s %s\n" "$status" "$count"
done

divider

# Section 3: Recent Activity
echo "## Recent Activity (last 10 issues updated)"
echo ""

issues_json=$(fetch "/api/companies/$CID/issues?status=todo,in_progress,in_review,blocked,done")

# Build agent ID->name lookup
agent_lookup=$(echo "$agents_json" | jq -r '[.[] | {(.id): .name}] | add // {}')

echo "$issues_json" | jq -r --argjson agents "$agent_lookup" '
  sort_by(.updatedAt) | reverse |
  ["ID", "Title", "Status", "Assignee", "Updated"],
  ["--", "-----", "------", "--------", "-------"],
  (.[:10][] | [
    .identifier,
    (.title | if length > 40 then .[:37] + "..." else . end),
    .status,
    (if .assigneeAgentId then ($agents[.assigneeAgentId] // "-") else "-" end),
    (.updatedAt | split("T")[0])
  ])
  | @tsv
' | column -t -s $'\t'

divider

echo "## Summary"
total=$(fetch "/api/companies/$CID/issues" | jq 'length')
agent_count=$(echo "$agents_json" | jq 'length')
echo "  $agent_count agents | $total total issues"
echo ""
echo "---"
echo "Dashboard v1.0 | Powered by Lifeosai"

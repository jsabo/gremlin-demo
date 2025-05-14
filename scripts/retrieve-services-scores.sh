#!/bin/bash
# Retrieve each team's services and scores with improved formatting

# Ensure required environment variables are set
: "${GREMLIN_API_KEY:?Environment variable GREMLIN_API_KEY not set}"
BASE_URL="https://api.gremlin.com/v1"

# Fetch all team IDs
TEAM_IDS=$(curl -s -X GET -H "Authorization: Key $GREMLIN_API_KEY" "$BASE_URL/teams" | jq -r '.[].identifier')

if [ -z "$TEAM_IDS" ]; then
  echo "No teams found."
  exit 1
fi

for TEAM_ID in $TEAM_IDS; do
  echo "Team: $TEAM_ID"
  echo "========================================"
  
  RESPONSE=$(curl -s -X GET -H "Authorization: Key $GREMLIN_API_KEY" "$BASE_URL/services?teamId=$TEAM_ID")
  if ! echo "$RESPONSE" | jq empty 2>/dev/null; then
    echo "Error: Invalid response for team $TEAM_ID."
    echo
    continue
  fi
  
  SERVICE_COUNT=$(echo "$RESPONSE" | jq '.items | length')
  if [ "$SERVICE_COUNT" -eq 0 ]; then
    echo "No services found."
    echo
    continue
  fi
  
  # Print table header
  printf "%-40s | %-6s\n" "Service Name" "Score"
  printf -- "----------------------------------------+--------\n"
  
  # List each service with its cached score
  echo "$RESPONSE" | jq -r '.items[] | "\(.name)|\(.cachedScore)"' | while IFS='|' read -r service score; do
    printf "%-40s | %-6s\n" "$service" "${score}%"
  done
  
  echo
done


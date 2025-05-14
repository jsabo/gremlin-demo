#!/bin/bash
# This script runs a scenario by GUID using the API key.
# Usage: ./run-scenario.sh <TEAM_ID> <SCENARIO_GUID>

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <TEAM_ID> <SCENARIO_GUID>"
  exit 1
fi

TEAM_ID="$1"
SCENARIO_GUID="$2"

# Ensure the GREMLIN_API_KEY environment variable is set
: "${GREMLIN_API_KEY:?Environment variable GREMLIN_API_KEY not set}"
BASE_URL="https://api.gremlin.com/v1"

echo "Running scenario with GUID $SCENARIO_GUID for team $TEAM_ID..."

curl -s -X POST \
  -H "Content-Type: application/json;charset=utf-8" \
  -H "Authorization: Key $GREMLIN_API_KEY" \
  "$BASE_URL/scenarios/$SCENARIO_GUID/runs?teamId=$TEAM_ID" \
  -d '{}'

echo "Scenario run triggered."


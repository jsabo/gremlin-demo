#!/bin/bash

# Ensure required environment variables are set
GREMLIN_TEAM_ID=${GREMLIN_TEAM_ID:?Environment variable GREMLIN_TEAM_ID not set}
GREMLIN_API_KEY=${GREMLIN_API_KEY:?Environment variable GREMLIN_API_KEY not set}
BASE_URL="https://api.gremlin.com/v1"

# Fetch the list of RM services
echo "Fetching list of RM services for team $GREMLIN_TEAM_ID..."
response=$(curl -s -X GET \
  -H "Authorization: Key $GREMLIN_API_KEY" \
  "$BASE_URL/services?teamId=$GREMLIN_TEAM_ID")

# Check if the response is valid JSON
if ! echo "$response" | jq empty 2>/dev/null; then
  echo "Failed to fetch RM services or received invalid response. Please check your API credentials."
  exit 1
fi

# Parse the RM services
services=$(echo "$response" | jq -c '.items[]')
if [[ -z "$services" ]]; then
  echo "No RM services found for team $GREMLIN_TEAM_ID."
  exit 1
fi

# Current timestamp for comparison
current_date=$(date +%s)

# Process each service
echo "Evaluating services..."
echo "---------------------------------------------"
for service in $(echo "$services"); do
  service_name=$(echo "$service" | jq -r '.name')
  service_id=$(echo "$service" | jq -r '.serviceId')
  reliability_score=$(echo "$service" | jq -r '.cachedScore')
  last_run_date=$(echo "$service" | jq -r '.modifiedDate')

  # Handle last_run_date conversion (macOS/BSD-compatible)
  if [[ "$last_run_date" != "null" ]]; then
    last_run_timestamp=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${last_run_date:0:19}" +%s 2>/dev/null)
    if [[ $? -ne 0 ]]; then
      days_since_last_run="unknown"
    else
      days_since_last_run=$(( (current_date - last_run_timestamp) / 86400 ))
    fi
  else
    days_since_last_run="unknown"
  fi

  # Determine pass or fail based on criteria
  status="Pass"
  if [[ "$reliability_score" -lt 80 || "$days_since_last_run" -gt 7 || "$days_since_last_run" == "unknown" ]]; then
    status="Fail"
  fi

  # Print service evaluation
  echo "Service: $service_name (ID: $service_id)"
  echo "  Reliability Score: ${reliability_score}%"
  if [[ "$days_since_last_run" != "unknown" ]]; then
    echo "  Last Run: $days_since_last_run days ago"
  else
    echo "  Last Run: Never"
  fi
  echo "  Status: $status"
  echo
done

echo "Service evaluations completed."


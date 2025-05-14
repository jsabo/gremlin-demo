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

echo "Fetching ELB names for each service's intelligent health checks..."
echo "-------------------------------------------------------------"

# Iterate through the services
for service in $(echo "$services"); do
  service_name=$(echo "$service" | jq -r '.name')
  service_id=$(echo "$service" | jq -r '.serviceId')

  # Extract ELB names from the service's awsTargets
  elb_names=$(echo "$service" | jq -r '.awsTargets[].name')

  if [[ -n "$elb_names" ]]; then
    echo "Service: $service_name (ID: $service_id)"
    echo "ELB Names:"
    echo "$elb_names" | sed 's/^/  - /' # Indent each ELB name for clarity
    echo
  else
    echo "Service: $service_name (ID: $service_id)"
    echo "No ELB names found."
    echo
  fi
done

echo "All services processed."


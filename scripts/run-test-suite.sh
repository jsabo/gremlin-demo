#!/bin/bash

# Default auto approval flag to false.
AUTO_APPROVE=false

# Process any flags that begin with '--'
while [[ "$1" == --* ]]; do
  case "$1" in
    --auto-approve)
      AUTO_APPROVE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if a team ID was provided as an argument; otherwise, use the GREMLIN_TEAM_ID environment variable.
if [ -n "$1" ]; then
  TEAM_ID="$1"
else
  TEAM_ID="${GREMLIN_TEAM_ID:?Environment variable GREMLIN_TEAM_ID not set and no team ID argument provided.}"
fi

# Ensure required environment variables are set
: "${GREMLIN_API_KEY:?Environment variable GREMLIN_API_KEY not set}"
BASE_URL="https://api.gremlin.com/v1"

# Fetch the list of RM services
echo "Fetching list of RM services for team $TEAM_ID..."
response=$(curl -s -X GET \
  -H "Authorization: Key $GREMLIN_API_KEY" \
  "$BASE_URL/services?teamId=$TEAM_ID")

# Check if the response is valid JSON
if ! echo "$response" | jq empty 2>/dev/null; then
  echo "Failed to fetch RM services or received invalid response. Please check your API credentials."
  exit 1
fi

# Parse and display the RM services
services=$(echo "$response" | jq -c '.items[]')
if [[ -z "$services" ]]; then
  echo "No RM services found for team $TEAM_ID."
  exit 1
fi

echo "Available RM Services:"
echo "$services" | jq -r '.name'

# Iterate through the services using a for loop
for service in $(echo "$services"); do
  service_name=$(echo "$service" | jq -r '.name')
  service_id=$(echo "$service" | jq -r '.serviceId')

  echo "Service: $service_name (ID: $service_id)"
  
  if [ "$AUTO_APPROVE" = true ]; then
    echo "Auto-approving full tests for $service_name..."
    answer="y"
  else
    echo "Do you want to run full tests for this service? (y/n)"
    read -p "Enter choice: " answer
  fi

  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Running full tests for $service_name..."
    curl -X POST \
      -H "Content-Type: application/json" \
      -H "Authorization: Key $GREMLIN_API_KEY" \
      "$BASE_URL/services/$service_id/baseline?teamId=$TEAM_ID" \
      -H "accept: */*" \
      -d '{}'

    if [[ $? -eq 0 ]]; then
      echo "Full tests for $service_name completed successfully."
    else
      echo "Failed to run full tests for $service_name."
    fi
  else
    echo "Skipping $service_name."
  fi
done

echo "All services processed."


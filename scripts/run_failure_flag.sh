#!/bin/bash

# Ensure required environment variables are set
: ${GREMLIN_TEAM_ID:?Environment variable GREMLIN_TEAM_ID not set}
: ${GREMLIN_API_KEY:?Environment variable GREMLIN_API_KEY not set}

BASE_URL="https://api.gremlin.com/v1"

echo "Fetching list of Failure Flag experiments for team $GREMLIN_TEAM_ID..."
response=$(curl -s -X GET \
  -H "Authorization: Key $GREMLIN_API_KEY" \
  "$BASE_URL/failure-flags/experiments?teamId=$GREMLIN_TEAM_ID")

# Check if the response is valid JSON
if ! echo "$response" | jq empty 2>/dev/null; then
  echo "Failed to fetch Failure Flag experiments or received an invalid response. Please check your API credentials."
  exit 1
fi

# Since the API returns an array, we can directly extract each element
experiments=$(echo "$response" | jq -c '.[]')

if [ -z "$experiments" ]; then
  echo "No Failure Flag experiments found for team $GREMLIN_TEAM_ID."
  exit 1
fi

echo "Available Failure Flag Experiments:"
echo "$experiments" | jq -r '.name'

# Iterate over each experiment using a while-read loop
echo "$experiments" | while IFS= read -r experiment; do
  experiment_name=$(echo "$experiment" | jq -r '.name')
  experiment_id=$(echo "$experiment" | jq -r '.id')

  echo "Experiment: $experiment_name (ID: $experiment_id)"
  read -p "Do you want to run this Failure Flag experiment? (y/n): " answer

  if [[ "$answer" =~ ^[yY]$ ]]; then
    # Prompt for custom parameters
    read -p "Enter Impact Probability (0-100): " impact_probability
    read -p "Enter Experiment Duration (e.g., '60s' or '5m'): " duration

    echo "Running Failure Flag experiment '$experiment_name' with Impact Probability: $impact_probability and Duration: $duration..."
    
    run_response=$(curl -s -X POST \
      -H "Content-Type: application/json" \
      -H "Authorization: Key $GREMLIN_API_KEY" \
      "$BASE_URL/failure-flags/experiments/$experiment_id/run?teamId=$GREMLIN_TEAM_ID" \
      -H "accept: */*" \
      -d "{\"impactProbability\": $impact_probability, \"duration\": \"$duration\"}")

    if [ $? -eq 0 ]; then
      echo "Experiment '$experiment_name' executed. Response:"
      echo "$run_response" | jq .
    else
      echo "Failed to run experiment '$experiment_name'."
    fi
  else
    echo "Skipping experiment '$experiment_name'."
  fi
done

echo "All experiments processed."


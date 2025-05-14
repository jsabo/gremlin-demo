#!/bin/bash
# This script fetches Failure Flag experiments for a given Gremlin team,
# then interactively prompts the user to run each experiment with custom parameters.
#
# Usage:
#   ./run_failure_flag.sh TEAM_ID
#   (Alternatively, set GREMLIN_TEAM_ID and GREMLIN_API_KEY as environment variables)

# Ensure required API key is set
: ${GREMLIN_API_KEY:?Environment variable GREMLIN_API_KEY not set}

# Use the first argument as the team ID; otherwise fall back to GREMLIN_TEAM_ID env variable.
if [ -n "$1" ]; then
  TEAM_ID="$1"
else
  : ${GREMLIN_TEAM_ID:?Environment variable GREMLIN_TEAM_ID not set}
  TEAM_ID="$GREMLIN_TEAM_ID"
fi

BASE_URL="https://api.gremlin.com/v1"

# Fetch the list of Failure Flag experiments for the team
echo "Fetching list of Failure Flag experiments for team $TEAM_ID..."
response=$(curl -s -X GET \
  -H "Authorization: Key $GREMLIN_API_KEY" \
  "$BASE_URL/failure-flags/experiments?teamId=$TEAM_ID")

# Verify that the response is valid JSON
if ! echo "$response" | jq empty 2>/dev/null; then
  echo "Error: Failed to fetch experiments. Please check your API credentials."
  exit 1
fi

# Extract experiments from the JSON response (one compact JSON object per experiment)
experiments=$(echo "$response" | jq -c '.[]')
if [ -z "$experiments" ]; then
  echo "No Failure Flag experiments found for team $TEAM_ID."
  exit 1
fi

# Display the names of available experiments
echo "Available Failure Flag Experiments:"
echo "$experiments" | jq -r '.name'

# Build an array of experiments (using a while-read loop for compatibility)
experiment_lines=()
while IFS= read -r line; do
  experiment_lines+=("$line")
done <<< "$experiments"

# Process each experiment
for experiment in "${experiment_lines[@]}"; do
  experiment_name=$(echo "$experiment" | jq -r '.name')
  experiment_id=$(echo "$experiment" | jq -r '.id')

  echo "Experiment: $experiment_name (ID: $experiment_id)"
  
  # Prompt user whether to run this experiment (force interactive input from /dev/tty)
  read -r -p "Do you want to run this Failure Flag experiment? (y/n): " answer < /dev/tty
  if [[ "$answer" =~ ^[yY]$ ]]; then
    # Prompt for additional parameters
    read -r -p "Enter Impact Probability (0-100): " impact_probability < /dev/tty
    read -r -p "Enter Experiment Duration (e.g., '60s' or '5m'): " duration < /dev/tty

    echo "Running Failure Flag experiment '$experiment_name'..."
    
    run_response=$(curl -s -X POST \
      -H "Content-Type: application/json" \
      -H "Authorization: Key $GREMLIN_API_KEY" \
      "$BASE_URL/failure-flags/experiments/$experiment_id/run?teamId=$TEAM_ID" \
      -H "accept: */*" \
      -d "{\"impactProbability\": $impact_probability, \"duration\": \"$duration\"}")

    echo "Response:"
    echo "$run_response" | jq .
  else
    echo "Skipping experiment '$experiment_name'."
  fi
done

echo "All experiments processed."


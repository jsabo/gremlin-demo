#!/bin/bash

# Check if the API key is set in the environment
if [ -z "$GREMLIN_API_KEY" ]; then
  echo "Error: GREMLIN_API_KEY environment variable is not set."
  echo "Please set it using: export GREMLIN_API_KEY='your_api_key_here'"
  exit 1
fi

# Prompt for team IDs
read -p "Enter a comma-separated list of team IDs: " team_ids

# Split the team IDs into an array
IFS=',' read -r -a team_array <<< "$team_ids"

# Function to fetch and display team and scenario details
fetch_team_scenarios() {
  local team_id="$1"

  echo -e "\nFetching information for team ID: $team_id..."

  # Fetch team info
  team_info=$(curl -s -X GET -H "Authorization: Key $GREMLIN_API_KEY" "https://api.gremlin.com/v1/teams" | jq -r ".[] | select(.identifier == \"$team_id\")")

  if [ -z "$team_info" ]; then
    echo "  Error: No team found with ID $team_id."
    return
  fi

  # Extract team name
  team_name=$(echo "$team_info" | jq -r '.name')

  echo "  Team Name: $team_name"

  # Fetch scenarios for the team
  scenarios=$(curl -s -X GET -H "Authorization: Key $GREMLIN_API_KEY" "https://api.gremlin.com/v1/scenarios?teamId=$team_id")

  if [ "$(echo "$scenarios" | jq length)" -eq 0 ]; then
    echo "  No scenarios found for this team."
    return
  fi

  echo "  Scenarios:"
  echo "$scenarios" | jq -r '.[] | "    - Scenario ID: \(.guid), Name: \(.name)"'
}

# Loop through each team ID
for team_id in "${team_array[@]}"; do
  fetch_team_scenarios "$team_id"
done


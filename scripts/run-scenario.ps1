# Usage: .\run-scenario.ps1 <TEAM_ID> <SCENARIO_GUID>

param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TeamId,
    [Parameter(Mandatory = $true, Position = 1)]
    [string]$ScenarioGuid
)

# Ensure the GREMLIN_API_KEY environment variable is set
$ApiKey = $env:GREMLIN_API_KEY
if (-not $ApiKey) {
    Write-Error "Environment variable GREMLIN_API_KEY not set."
    exit 1
}
$BaseUrl = "https://api.gremlin.com/v1"

Write-Host "Running scenario with GUID $ScenarioGuid for team $TeamId..."

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/scenarios/$ScenarioGuid/runs?teamId=$TeamId" `
        -Headers @{ "Content-Type" = "application/json;charset=utf-8"; "Authorization" = "Key $ApiKey" } `
        -Method Post -Body '{}'
    Write-Host "Scenario run triggered."
} catch {
    Write-Error "Failed to trigger scenario. Please check your API key, Team ID, and Scenario GUID."
}


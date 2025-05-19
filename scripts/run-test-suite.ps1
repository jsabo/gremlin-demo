# Default values
$AutoApprove = $false
$TeamId = $null

# Parse command-line arguments
foreach ($arg in $args) {
    if ($arg -eq '--auto-approve' -or $arg -eq '-AutoApprove') {
        $AutoApprove = $true
    } elseif (-not $TeamId -and $arg -notlike '--*') {
        $TeamId = $arg
    } elseif ($arg -like '--*') {
        Write-Error "Unknown option: $arg"
        exit 1
    }
}

# Check if a team ID was provided as an argument; otherwise, use the GREMLIN_TEAM_ID environment variable.
if (-not $TeamId) {
    $TeamId = $env:GREMLIN_TEAM_ID
    if (-not $TeamId) {
        Write-Error "Environment variable GREMLIN_TEAM_ID not set and no team ID argument provided."
        exit 1
    }
}

# Ensure required environment variables are set
$ApiKey = $env:GREMLIN_API_KEY
if (-not $ApiKey) {
    Write-Error "Environment variable GREMLIN_API_KEY not set."
    exit 1
}
$BaseUrl = "https://api.gremlin.com/v1"

Write-Host "Fetching list of RM services for team $TeamId..."

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/services?teamId=$TeamId" -Headers @{ Authorization = "Key $ApiKey" } -Method Get
} catch {
    Write-Error "Failed to fetch RM services or received invalid response. Please check your API credentials."
    exit 1
}

if (-not $response.items -or $response.items.Count -eq 0) {
    Write-Host "No RM services found for team $TeamId."
    exit 1
}

Write-Host "Available RM Services:"
$response.items | ForEach-Object { Write-Host $_.name }

# Iterate through the services
foreach ($service in $response.items) {
    $service_name = $service.name
    $service_id = $service.serviceId

    Write-Host "Service: $service_name (ID: $service_id)"

    if ($AutoApprove) {
        Write-Host "Auto-approving full tests for $service_name..."
        $answer = "y"
    } else {
        $answer = Read-Host "Do you want to run full tests for this service? (y/n)"
    }

    if ($answer -eq "y" -or $answer -eq "Y") {
        Write-Host "Running full tests for $service_name..."
        try {
            Invoke-RestMethod -Uri "$BaseUrl/services/$service_id/baseline?teamId=$TeamId" `
                              -Headers @{ "Content-Type" = "application/json"; "Authorization" = "Key $ApiKey"; "accept" = "*/*" } `
                              -Method Post -Body '{}' | Out-Null
            Write-Host "Full tests for $service_name completed successfully."
        } catch {
            Write-Warning "Failed to run full tests for $service_name."
        }
    } else {
        Write-Host "Skipping $service_name."
    }
}

Write-Host "All services processed."

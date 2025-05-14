# Gremlin Demo

This repository contains scripts and examples to integrate with Gremlin SaaS. The provided examples cover managing service annotations, running service reliability tests, and interacting with the Honeycomb API.

## Manage Service Annotations

Use these scripts to manage annotations for various services.

### Storefront Annotations

Run the following command to manage storefront annotations:

```bash
./scripts/manage-storefront-annotations.sh <Action> <Suffix> <Team ID> <Namespace>
```

**Example:**

```bash
./scripts/manage-storefront-annotations.sh add Aws b8d5b49a-36cb-461f-95b4-9a36cb061ffe storefront
./scripts/manage-storefront-annotations.sh add Azure bf0c2a69-5d62-4cd4-8c2a-695d623cd419 storefront
```

## Run Service Reliability Tests

Execute the following script to run service reliability tests:

```bash
./scripts/test-services.sh <Team ID>
```

**Example:**

```bash
./scripts/test-services.sh 0e1177cd-d46b-43e4-9177-cdd46b33e402
```

## Honeycomb API

These examples demonstrate how to interact with the Honeycomb API.

### List All Triggers

Retrieve all triggers for the frontend proxy:

```bash
curl -s -X GET https://api.honeycomb.io/1/triggers/frontendproxy \
  -H "X-Honeycomb-Team: $TF_VAR_honeycomb_storefront_api_key" | jq .
```

### Get All SLOs

Retrieve all Service Level Objectives (SLOs) for the frontend proxy:

```bash
curl -s -X GET https://api.honeycomb.io/1/slos/frontendproxy \
  -H "X-Honeycomb-Team: $TF_VAR_honeycomb_storefront_api_key" | jq .
```

### Markers

To create markers, use the following details:

- **Request URL:**  
  `https://api.honeycomb.io/1/markers/__all__`

 > **Note:** The dataset slug or use `__all__` for endpoints that support environment-wide operations.

- **Custom Headers:**  
  - **Key:** `X-Honeycomb-Team`  
  - **Value:** `<Honeycomb API Key>`

- **Payload Example:**

  ```json
  {
    "message": "Gremlin ${ATTACK_TYPE} attack (ID: ${ATTACK_ID}) is ${STATUS} (Final Stage: ${STAGE}) from ${SOURCE}",
    "type": "attack-${ATTACK_TYPE}",
    "url": "https://app.gremlin.com/attacks/${ATTACK_ID}"
  }
  ```

### Dynatrace

Get Dynatrace Synthetic Monitor Locations

```
curl -X GET -s -H "Authorization: Api-Token $TF_VAR_dnyatrace_api_token" https://qpm46186.live.dynatrace.com/api/v1/synthetic/locations | jq '.locations[] | select(.name=="Dublin" and .cloudPlatform=="AMAZON_EC2")'
```

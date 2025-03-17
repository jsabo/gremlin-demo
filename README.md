# Gremlin Demo

This repository contains scripts and examples to integrate with Gremlin SaaS. The provided examples cover managing service annotations, running service reliability tests, and interacting with the Honeycomb API.

## Table of Contents
- [Manage Service Annotations](#manage-service-annotations)
  - [Storefront Annotations](#storefront-annotations)
  - [WordPress Annotations](#wordpress-annotations)
- [Run Service Reliability Tests](#run-service-reliability-tests)
- [Honeycomb API](#honeycomb-api)
  - [List All Triggers](#list-all-triggers)
  - [Get All SLOs](#get-all-slos)
  - [Markers](#markers)
- [Contributing](#contributing)

---

## Manage Service Annotations

Use these scripts to manage annotations for various services.

### Storefront Annotations

Run the following command to manage storefront annotations:

```bash
./scripts/manage-storefront-annotations.sh <Action> <Suffix> <Team ID> <Namespace>
```

**Example:**

```bash
./scripts/manage-storefront-annotations.sh add East b8d5b49a-36cb-461f-95b4-9a36cb061ffe storefront
```

### WordPress Annotations

Run the following command to manage WordPress annotations:

```bash
./scripts/manage-wordpress-annotations.sh <Action> <Suffix> <Team ID> <Namespace>
```

**Examples:**

```bash
./scripts/manage-wordpress-annotations.sh add Test 0e1177cd-d46b-43e4-9177-cdd46b33e402 wordpress-test
```

```bash
./scripts/manage-wordpress-annotations.sh add Prod 0e1177cd-d46b-43e4-9177-cdd46b33e402 wordpress-prod
```

---

## Run Service Reliability Tests

Execute the following script to run service reliability tests:

```bash
./scripts/test-services.sh <Team ID>
```

**Example:**

```bash
./scripts/test-services.sh 0e1177cd-d46b-43e4-9177-cdd46b33e402
```

---

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

 > **Note:** The dataset slug or use `__all__` for endpoints that support env    ironment-wide operations.

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

---

## Contributing

Feel free to submit issues or pull requests to enhance these examples further. 


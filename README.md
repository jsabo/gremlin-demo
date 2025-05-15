# Gremlin Demo Environments

This repository provides infrastructure as code (IaC) to deploy managed Kubernetes clusters across multiple cloud providers, along with reliability tooling including **Gremlin**, **OpenTelemetry Demo**, **Honeycomb**, and **Dynatrace**.

## 🚀 Overview

Use this repository to:

* Provision managed Kubernetes clusters on AWS, Azure, and GCP.
* Deploy Gremlin for fault injection testing.
* Deploy the OpenTelemetry demo application to generate observability signals.
* Configure Honeycomb and Dynatrace integrations.
* Run scripts for chaos engineering experiments, health checks, and annotation management.

## 🌐 Cloud Environments

Each cloud-specific folder includes Terraform code to deploy a Kubernetes cluster and related components:

* **AWS** (`./aws-us-east-1`)

  * EKS + supporting components
  * Helm charts for Gremlin, OpenTelemetry Demo, WordPress, and more

* **Azure** (`./azure-northeurope`)

  * AKS + VNet module
  * Helm charts for Gremlin and OpenTelemetry Demo

* **GCP** (`./gke-us-east1`)

  * GKE (Standard + Autopilot)
  * Helm charts for cert-manager, trust-manager, and RabbitMQ Operator

## 🧰 Scripts

Scripts are available under the `./scripts/` directory for operational tasks:

### 📎 Manage Annotations

* **Storefront Annotations:**

  ```bash
  ./scripts/manage-storefront-annotations.sh <add|remove> <Suffix> <Team ID> <Namespace>
  ```

* **WordPress Annotations:**

  ```bash
  ./scripts/manage-wordpress-annotations.sh <add|remove> <Suffix> <Team ID> <Namespace>
  ```

### 🔬 Run Reliability Tests

* Run tests for services in a given team:

  ```bash
  ./scripts/test-services.sh <Team ID>
  ```

### 🛠 Other Utilities

* `run-scenario.sh`: Execute saved Gremlin scenarios
* `retrieve-services-scores.sh`: Fetch service health scores
* `evaluate-service-health.sh`: Evaluate cluster and service health
* `run-failure-flag-experiments.sh`: Test Failure Flags integration

## 📊 Observability Integrations

### 🐝 Honeycomb

Interact with the Honeycomb API:

* **List Triggers:**

  ```bash
  curl -s -X GET https://api.honeycomb.io/1/triggers/frontendproxy \
    -H "X-Honeycomb-Team: $TF_VAR_honeycomb_storefront_api_key" | jq .
  ```

* **Get SLOs:**

  ```bash
  curl -s -X GET https://api.honeycomb.io/1/slos/frontendproxy \
    -H "X-Honeycomb-Team: $TF_VAR_honeycomb_storefront_api_key" | jq .
  ```

* **Send Marker Example:**

  ```json
  {
    "message": "Gremlin ${ATTACK_TYPE} attack (ID: ${ATTACK_ID}) is ${STATUS} (Final Stage: ${STAGE}) from ${SOURCE}",
    "type": "attack-${ATTACK_TYPE}",
    "url": "https://app.gremlin.com/attacks/${ATTACK_ID}"
  }
  ```

### 📡 Dynatrace

* Get synthetic monitor locations filtered by name and platform:

  ```bash
  curl -X GET -s -H "Authorization: Api-Token $TF_VAR_dnyatrace_api_token" \
    https://qpm46186.live.dynatrace.com/api/v1/synthetic/locations | \
    jq '.locations[] | select(.name=="Dublin" and .cloudPlatform=="AMAZON_EC2")'
  ```

## 📁 Directory Structure

```
aws-us-east-1/         # AWS infrastructure and Helm values
azure-northeurope/     # Azure infrastructure with VNet modules
gke-us-east1/          # GCP infrastructure for GKE clusters
scripts/               # Utility and automation scripts
manifests/             # Kubernetes manifests for demo apps
docs/                  # Documentation (e.g., Cloud Foundry on AWS)
```

## 📄 License

This project is licensed under the terms of the [MIT License](./LICENSE).


# gremlin-demo


### Manage Service Annotations

```bash
./scripts/manage-storefront-annotations.sh <Action> <Suffix> <Team ID> <Namespace>
./scripts/manage-storefront-annotations.sh add East b8d5b49a-36cb-461f-95b4-9a36cb061ffe storefront
```

```bash
./scripts/manage-wordpress-annotations.sh <Action> <Suffix> <Team ID> <Namespace>
./scripts/manage-wordpress-annotations.sh add Test 0e1177cd-d46b-43e4-9177-cdd46b33e402 wordpress-test
./scripts/manage-wordpress-annotations.sh add Prod 0e1177cd-d46b-43e4-9177-cdd46b33e402 wordpress-prod
```

### Run Service Reliability Tests

```bash
./scripts/test-services.sh <Team ID>
./scripts/test-services.sh 0e1177cd-d46b-43e4-9177-cdd46b33e402
```

### Honeycomb API

List All Triggers

```bash
curl -s -X GET https://api.honeycomb.io/1/triggers/frontendproxy \
  -H "X-Honeycomb-Team: $TF_VAR_honeycomb_storefront_api_key" | jq .
```

Get All SLOs

```bash
curl -s -X GET https://api.honeycomb.io/1/slos/frontendproxy \
  -H "X-Honeycomb-Team: $TF_VAR_honeycomb_storefront_api_key" | jq .
```

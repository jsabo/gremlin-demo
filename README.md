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

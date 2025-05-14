#!/bin/bash

# Usage: ./script.sh [add|remove] [optional_suffix] [team_id]

set -euo pipefail

ACTION=${1:-}
SUFFIX=${2:-}
TEAM_ID=${3:-}
NAMESPACE="storefront"

if [[ "$ACTION" != "add" && "$ACTION" != "remove" ]]; then
  echo "Invalid option. Use 'add' to add annotations or 'remove' to remove annotations."
  exit 1
fi

if [[ "$ACTION" == "add" && -z "$TEAM_ID" ]]; then
  echo "When using 'add', you must provide a team ID as the third argument."
  exit 1
fi

SERVICES=(
  "accounting:Accounting-Service"
  "ad:Ad-Service"
  "cart:Cart-Service"
  "checkout:Checkout-Service"
  "currency:Currency-Service"
  "email:Email-Service"
  "fraud-detection:Fraud-Detection-Service"
  "frontend:Frontend"
  "frontend-proxy:Frontend-Proxy"
  "image-provider:Image-Provider"
  "kafka:Kafka-Service"
  "payment:Payment-Service"
  "product-catalog:Product-Catalog-Service"
  "quote:Quote-Service"
  "recommendation:Recommendation-Service"
  "shipping:Shipping-Service"
  "valkey-cart:Valkey-Cart-Service"
)

for SERVICE in "${SERVICES[@]}"; do
  DEPLOYMENT_NAME="${SERVICE%%:*}"
  SERVICE_ID="${SERVICE##*:}"

  [[ -n "$SUFFIX" ]] && SERVICE_ID+="-$SUFFIX"

  if [[ "$ACTION" == "add" ]]; then
    echo "Annotating deployment $DEPLOYMENT_NAME with service-id=$SERVICE_ID and team-id=$TEAM_ID"
    kubectl annotate deployment "$DEPLOYMENT_NAME" gremlin.com/service-id="$SERVICE_ID" --overwrite -n "$NAMESPACE"
    kubectl annotate deployment "$DEPLOYMENT_NAME" gremlin.com/team-id="$TEAM_ID" --overwrite -n "$NAMESPACE"
  else
    echo "Removing annotations from deployment $DEPLOYMENT_NAME"
    kubectl annotate deployment "$DEPLOYMENT_NAME" gremlin.com/service-id- --overwrite -n "$NAMESPACE"
    kubectl annotate deployment "$DEPLOYMENT_NAME" gremlin.com/team-id- --overwrite -n "$NAMESPACE"
  fi

done


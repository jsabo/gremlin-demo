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
  "accountingservice:Accounting-Service"
  "adservice:Ad-Service"
  "cartservice:Cart-Service"
  "checkoutservice:Checkout-Service"
  "currencyservice:Currency-Service"
  "emailservice:Email-Service"
  "frauddetectionservice:Fraud-Detection-Service"
  "frontend:Frontend"
  "frontendproxy:Frontend-Proxy"
  "imageprovider:Image-Provider"
  "kafka:Kafka-Service"
  "paymentservice:Payment-Service"
  "productcatalogservice:Product-Catalog-Service"
  "quoteservice:Quote-Service"
  "recommendationservice:Recommendation-Service"
  "shippingservice:Shipping-Service"
  "valkey:Valkey"
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


#!/bin/bash

# Usage: ./script.sh [add|remove] [optional_suffix] [team_id]

set -euo pipefail

ACTION=${1:-}
SUFFIX=${2:-}
TEAM_ID=${3:-}
NAMESPACE="otel-demo"

if [[ "$ACTION" != "add" && "$ACTION" != "remove" ]]; then
  echo "Invalid option. Use 'add' to add annotations or 'remove' to remove annotations."
  exit 1
fi

if [[ "$ACTION" == "add" && -z "$TEAM_ID" ]]; then
  echo "When using 'add', you must provide a team ID as the third argument."
  exit 1
fi

SERVICES=(
  "otel-demo-accountingservice:accounting-service"
  "otel-demo-adservice:ad-service"
  "otel-demo-cartservice:cart-service"
  "otel-demo-checkoutservice:checkout-service"
  "otel-demo-currencyservice:currency-service"
  "otel-demo-emailservice:email-service"
  "otel-demo-frauddetectionservice:fraud-detection-service"
  "otel-demo-frontend:frontend"
  "otel-demo-frontendproxy:frontend-proxy"
  "otel-demo-imageprovider:image-provider"
  "otel-demo-kafka:kafka"
  "otel-demo-paymentservice:payment-service"
  "otel-demo-productcatalogservice:product-catalog-service"
  "otel-demo-quoteservice:quote-service"
  "otel-demo-recommendationservice:recommendation-service"
  "otel-demo-shippingservice:shipping-service"
  "otel-demo-valkey:valkey"
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


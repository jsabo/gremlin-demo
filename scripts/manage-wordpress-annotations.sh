#!/bin/bash
# Usage: ./script.sh [add|remove] [optional_suffix] [team_id] [namespace]
# Examples:
#   ./script.sh add dev-team1 wordpress-dev
#   ./script.sh remove "" wordpress-dev

set -euo pipefail

ACTION=${1:-}
SUFFIX=${2:-}
TEAM_ID=${3:-}
NAMESPACE=${4:-"wordpress-dev"}

if [[ "$ACTION" != "add" && "$ACTION" != "remove" ]]; then
  echo "Invalid option. Use 'add' to add annotations or 'remove' to remove annotations."
  exit 1
fi

if [[ "$ACTION" == "add" && -z "$TEAM_ID" ]]; then
  echo "When using 'add', you must provide a team ID as the third argument."
  exit 1
fi

# Define deployments to annotate (format: "resource_name:service_id")
DEPLOYMENTS=(
  "wordpress:Wordpress"
  "wordpress-memcached:Memcached"
)

# Define statefulsets to annotate (format: "resource_name:service_id")
STATEFULSETS=(
  "wordpress-mariadb:Mariadb"
)

# Annotate deployments
for SERVICE in "${DEPLOYMENTS[@]}"; do
  DEPLOYMENT_NAME="${SERVICE%%:*}"
  SERVICE_ID="${SERVICE##*:}"

  # Append suffix if provided
  [[ -n "$SUFFIX" ]] && SERVICE_ID+="-$SUFFIX"

  if [[ "$ACTION" == "add" ]]; then
    echo "Annotating deployment '$DEPLOYMENT_NAME' with gremlin.com/service-id=$SERVICE_ID and gremlin.com/team-id=$TEAM_ID in namespace $NAMESPACE"
    kubectl annotate deployment "$DEPLOYMENT_NAME" gremlin.com/service-id="$SERVICE_ID" --overwrite -n "$NAMESPACE"
    kubectl annotate deployment "$DEPLOYMENT_NAME" gremlin.com/team-id="$TEAM_ID" --overwrite -n "$NAMESPACE"
  else
    echo "Removing annotations from deployment '$DEPLOYMENT_NAME' in namespace $NAMESPACE"
    kubectl annotate deployment "$DEPLOYMENT_NAME" gremlin.com/service-id- --overwrite -n "$NAMESPACE"
    kubectl annotate deployment "$DEPLOYMENT_NAME" gremlin.com/team-id- --overwrite -n "$NAMESPACE"
  fi
done

# Annotate statefulsets
for SERVICE in "${STATEFULSETS[@]}"; do
  STATEFULSET_NAME="${SERVICE%%:*}"
  SERVICE_ID="${SERVICE##*:}"

  # Append suffix if provided
  [[ -n "$SUFFIX" ]] && SERVICE_ID+="-$SUFFIX"

  if [[ "$ACTION" == "add" ]]; then
    echo "Annotating statefulset '$STATEFULSET_NAME' with gremlin.com/service-id=$SERVICE_ID and gremlin.com/team-id=$TEAM_ID in namespace $NAMESPACE"
    kubectl annotate statefulset "$STATEFULSET_NAME" gremlin.com/service-id="$SERVICE_ID" --overwrite -n "$NAMESPACE"
    kubectl annotate statefulset "$STATEFULSET_NAME" gremlin.com/team-id="$TEAM_ID" --overwrite -n "$NAMESPACE"
  else
    echo "Removing annotations from statefulset '$STATEFULSET_NAME' in namespace $NAMESPACE"
    kubectl annotate statefulset "$STATEFULSET_NAME" gremlin.com/service-id- --overwrite -n "$NAMESPACE"
    kubectl annotate statefulset "$STATEFULSET_NAME" gremlin.com/team-id- --overwrite -n "$NAMESPACE"
  fi
done


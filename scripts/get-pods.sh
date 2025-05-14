kubectl get pods -n s3app -o json | jq --argjson nodes "$(kubectl get nodes -o json)" -r '
  .items[] |
  . as $pod |
  ($nodes.items[] | select(.metadata.name == $pod.spec.nodeName) | .metadata.labels["topology.kubernetes.io/zone"]) as $zone |
  "\($pod.metadata.name)\t\($zone)"
'


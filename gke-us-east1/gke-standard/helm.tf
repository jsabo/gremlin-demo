locals {
  cert_manager_chart_version      = "1.16.3"
  trust_manager_chart_version     = "0.12.0"
  rabbitmq_operator_chart_version = "4.4.10"
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v${local.cert_manager_chart_version}"
  namespace        = "cert-manager"
  create_namespace = true

  values = [
    templatefile("${path.module}/helm_values/values-cert-manager.yaml", {})
  ]
}

resource "helm_release" "trust_manager" {
  name             = "trust-manager"
  chart            = "trust-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v${local.trust_manager_chart_version}"
  namespace        = helm_release.cert_manager.namespace
  create_namespace = false

  values = [
    templatefile("${path.module}/helm_values/values-trust-manager.yaml", {})
  ]
}

resource "helm_release" "rabbitmq_operator" {
  name             = "rabbitmq-cluster-operator"
  chart            = "rabbitmq-cluster-operator"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  version          = local.rabbitmq_operator_chart_version
  namespace        = "rabbitmq"
  create_namespace = true

  values = [
    templatefile("${path.module}/helm_values/values-rabbitmq-operator.yaml", {})
  ]
}

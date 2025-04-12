data "terraform_remote_state" "azure_tfstate" {
  backend = "local"
  config = {
    path = "${path.root}/../azure/terraform.tfstate"
  }
}

provider "kubernetes" {
  host                   = local.cluster_host
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
  client_certificate     = base64decode(local.cluster_client_certificate)
  client_key             = base64decode(local.cluster_client_key)
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_host
    cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
    client_certificate     = base64decode(local.cluster_client_certificate)
    client_key             = base64decode(local.cluster_client_key)
  }
}

locals {
  cluster_name                 = data.terraform_remote_state.azure_tfstate.outputs.cluster_name
  cluster_host                 = data.terraform_remote_state.azure_tfstate.outputs.cluster_host
  cluster_ca_certificate       = data.terraform_remote_state.azure_tfstate.outputs.cluster_ca_certificate
  cluster_client_certificate   = data.terraform_remote_state.azure_tfstate.outputs.cluster_client_certificate
  cluster_client_key           = data.terraform_remote_state.azure_tfstate.outputs.cluster_client_key
  cluster_kube_config          = data.terraform_remote_state.azure_tfstate.outputs.cluster_kube_config
  gremlin_team_id              = var.gremlin_team_id
  gremlin_team_secret          = var.gremlin_team_secret
  gremlin_chart_version        = var.gremlin_chart_version
  otel_demo_chart_version      = var.otel_demo_chart_version
  honeycomb_storefront_api_key = var.honeycomb_storefront_api_key
}

resource "helm_release" "gremlin" {
  name             = "gremlin"
  chart            = "gremlin"
  repository       = "https://helm.gremlin.com"
  version          = "v${local.gremlin_chart_version}"
  namespace        = "gremlin"
  create_namespace = true
  values = [templatefile("${path.module}/helm_values/values-gremlin.yaml", {
    gremlin_team_id     = local.gremlin_team_id
    gremlin_team_secret = local.gremlin_team_secret
    gremlin_cluster_id  = local.cluster_name
  })]
}

resource "helm_release" "opentelemetry-demo" {
  name             = "otel-demo"
  chart            = "opentelemetry-demo"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  version          = local.otel_demo_chart_version
  namespace        = "storefront"
  create_namespace = true
  values = [templatefile("${path.module}/helm_values/values-opentelemetry-demo.yaml", {
    gremlin_team_id              = local.cluster_name
    gremlin_cluster_id           = local.cluster_name
    honeycomb_storefront_api_key = local.honeycomb_storefront_api_key
  })]
}

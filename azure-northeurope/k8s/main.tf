data "terraform_remote_state" "aws_tfstate" {
  backend = "local"
  config = {
    path = "${path.root}/../aws/terraform.tfstate"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = local.cluster_name
}

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = base64decode(local.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", local.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = base64decode(local.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", local.cluster_name]
    }
  }
}

locals {
  cluster_name                       = data.terraform_remote_state.aws_tfstate.outputs.cluster_name
  cluster_endpoint                   = data.terraform_remote_state.aws_tfstate.outputs.cluster_endpoint
  cluster_version                    = data.terraform_remote_state.aws_tfstate.outputs.cluster_version
  oidc_provider_arn                  = data.terraform_remote_state.aws_tfstate.outputs.oidc_provider_arn
  cluster_certificate_authority_data = data.terraform_remote_state.aws_tfstate.outputs.cluster_certificate_authority_data
  region                             = var.region
  webhook_bind_port_metrics_server   = 30000
  webhook_bind_port_awslb_controller = 30001
  gremlin_team_id                    = var.gremlin_team_id
  gremlin_team_secret                = var.gremlin_team_secret
  gremlin_chart_version              = var.gremlin_chart_version
  otel_demo_chart_version            = var.otel_demo_chart_version
  datadog_api_key                    = var.datadog_api_key
  datadog_site                       = var.datadog_site

  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = local.cluster_name
      cluster = {
        certificate-authority-data = local.cluster_certificate_authority_data
        server                     = local.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = local.cluster_name
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })
  tags = {}
}

module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  cluster_name      = local.cluster_name
  cluster_endpoint  = local.cluster_endpoint
  cluster_version   = local.cluster_version
  oidc_provider_arn = local.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  enable_metrics_server = true
  metrics_server = {
    name          = "metrics-server"
    chart_version = "3.10.0"
    repository    = "https://kubernetes-sigs.github.io/metrics-server/"
    namespace     = "kube-system"
    values = [templatefile("${path.module}/helm_values/values-metrics-server.yaml", {
      webhook_bind_port_metrics_server = "${local.webhook_bind_port_metrics_server}"
    })]
  }

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    name       = "aws-load-balancer-controller"
    chart      = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    version    = "1.4.8"
    namespace  = "kube-system"
    values = [templatefile("${path.module}/helm_values/values-aws-load-balancer-controller.yaml", {
      clusterName                        = "${local.cluster_name}"
      region                             = "${local.region}"
      webhook_bind_port_awslb_controller = "${local.webhook_bind_port_awslb_controller}"
    })]
  }

  enable_ingress_nginx = false
  ingress_nginx = {
    name       = "ingress"
    chart      = "ingress-nginx"
    repository = "https://kubernetes.github.io/ingress-nginx"
    version    = "v4.5.2"
    namespace  = "ingress"
    values     = [templatefile("${path.module}/helm_values/values-nginx-ingress.yaml", {})]
  }

  tags = {}
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
  namespace        = "otel-demo"
  create_namespace = true
  values = [templatefile("${path.module}/helm_values/values-opentelemetry-demo.yaml", {
    gremlin_team_id    = local.cluster_name
    datadog_api_key    = local.datadog_api_key
    datadog_site       = local.datadog_site
    gremlin_cluster_id = local.cluster_name
  })]
}

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}

locals {
  name                      = var.name
  region                    = var.region
  vpc_cidr                  = var.vpc_cidr
  secondary_vpc_cidr        = var.secondary_vpc_cidr
  cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr
  azs                       = slice(data.aws_availability_zones.available.names, 0, 2)
  desired_size              = var.desired_size
  instance_type             = var.instance_type
  ami_type                  = var.ami_type
  key_name                  = var.ssh_keyname
  cluster_version           = var.cluster_version

  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = var.name
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = var.name
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

  tags = var.tags
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.10"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = slice(module.vpc.private_subnets, 0, 2)
  cluster_service_ipv4_cidr = local.cluster_service_ipv4_cidr

  cluster_enabled_log_types   = []
  create_cloudwatch_log_group = false

  eks_managed_node_groups = {
    demo = {
      name           = local.name
      instance_types = ["${local.instance_type}"]
      ami_type       = "${local.ami_type}"

      min_size     = 0
      max_size     = 8
      desired_size = local.desired_size

      attach_cluster_primary_security_group = true
      disk_size = 100

      key_name = local.key_name

      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
        additional               = aws_iam_policy.additional.arn
      }

      pre_bootstrap_user_data = <<-EOT
        yum install -y amazon-ssm-agent kernel-devel-`uname -r` iproute-tc
        yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
        curl -o /etc/yum.repos.d/jdoss-wireguard-epel-7.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
        yum install wireguard-dkms wireguard-tools -y
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

      tags = local.tags
    }

    gpe = {
      name           = "sabodotio-gpe"
      instance_types = ["r7i.xlarge"]
      ami_type       = "${local.ami_type}"

      min_size     = 3
      max_size     = 3
      desired_size = 3

      attach_cluster_primary_security_group = true
      disk_size = 100

      key_name = local.key_name

      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
        additional               = aws_iam_policy.additional.arn
      }

      pre_bootstrap_user_data = <<-EOT
        yum install -y amazon-ssm-agent kernel-devel-`uname -r` iproute-tc
        yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
        curl -o /etc/yum.repos.d/jdoss-wireguard-epel-7.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
        yum install wireguard-dkms wireguard-tools -y
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

      tags = local.tags
    }
  }

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  fargate_profiles = {
    fargate = {
      name = "fargate"
      selectors = [{
        namespace = "fargate"
      }]
      subnet_ids = slice(module.vpc.private_subnets, 0, 2)
      tags       = local.tags
    }
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  # Fix for AWS LB Controller (https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1986)
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.name}" = null
  }
  
  tags = local.tags
}

################################################################################
# Additional Resources
################################################################################

resource "aws_iam_policy" "additional" {
  name   = "${local.name}-additional"
  policy = file("${path.cwd}/min-iam-policy.json")
}

# Create the IAM Policy for Gremlin Access
resource "aws_iam_policy" "gremlin_policy" {
  name   = "${local.name}-gremlin-access-policy"
  policy = file("${path.module}/gremlin-policy.json")
}

# Create the IAM Role with Custom Trust Policy
resource "aws_iam_role" "gremlin_role" {
  name               = "${local.name}-gremlin-role"
  assume_role_policy = file("${path.module}/gremlin-trust-policy.json")
}

# Attach the Gremlin Policy to the Role
resource "aws_iam_role_policy_attachment" "gremlin_policy_attachment" {
  role       = aws_iam_role.gremlin_role.name
  policy_arn = aws_iam_policy.gremlin_policy.arn
}

# Attach the AWS Managed SecurityAudit Policy to the Role
resource "aws_iam_role_policy_attachment" "security_audit_policy_attachment" {
  role       = aws_iam_role.gremlin_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

################################################################################
# AWS Virtual Private Cloud Pattern
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.0.0"

  name = local.name
  cidr = local.vpc_cidr

  secondary_cidr_blocks = [local.secondary_vpc_cidr] # can add up to 5 total CIDR blocks

  azs = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 10)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.secondary_vpc_cidr, 4, k)]

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  intra_subnet_tags = {}

  tags = local.tags
}

# Create an EKS Cluster with Nodegroups in Private subnet
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.10.0"
  cluster_name    = var.clustername
  cluster_version = var.eks_version
  subnet_ids      = var.private_subnets
  vpc_id          = var.vpc_id
  enable_irsa     = true

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {

    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # Default Settings applicable to all node groups
  eks_managed_node_group_defaults = {
    ami_type          = "AL2_x86_64"
    disk_size         = 50
    ebs_optimized     = true
    enable_monitoring = true
    instance_types    = var.instance_types
    capacity_type     = "ON_DEMAND"
    update_config = {
      max_unavailable_percentage = 50
    }
  }

  eks_managed_node_groups = {

    system = {
      name            = "system"
      use_name_prefix = true

      tags = {
        Name              = "system"
        Environment       = var.environment
        terraform-managed = "true"
      }
    },
    app = {
      name            = "app"
      use_name_prefix = true

      tags = {
        Name              = "app"
        Environment       = var.environment
        terraform-managed = "true"
      }
    }
  }

  cluster_endpoint_public_access = true
  manage_aws_auth_configmap      = true

  # aws_auth_roles = [
  #   {
  #     rolearn  = module.eks_managed_node_group.iam_role_arn
  #     username = "system:node:{{EC2PrivateDNSName}}"
  #     groups = [
  #       "system:bootstrappers",
  #       "system:nodes",
  #     ]
  #   },
  #   {
  #     rolearn  = module.self_managed_node_group.iam_role_arn
  #     username = "system:node:{{EC2PrivateDNSName}}"
  #     groups = [
  #       "system:bootstrappers",
  #       "system:nodes",
  #     ]
  #   }
  # ]

  tags = {
    Name              = var.clustername
    Environment       = var.environment
    terraform-managed = "true"
  }

}
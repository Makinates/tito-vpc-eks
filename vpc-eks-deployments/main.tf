provider "aws" {
  region = "us-east-1"
}

/*
Note-1:  AWS Credentials Profile (profile = "default") configured on my local desktop terminal  
$HOME/.aws/credentials
*/


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"
  cluster_name    = "tito-cluster"
  #cluster_version = var.kubernetes_version
  subnet_ids      = aws_subnet.public_subnet[*].id

  # enable_irsa = true




  tags = {
    cluster = "tito-cluster"
  }

  vpc_id = aws_vpc.t-vpc.id

  eks_managed_node_group_defaults = {
    # ami_type               = "AL2_x86_64"
    instance_types         = ["t2.micro"]
    # vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {

    node_group = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

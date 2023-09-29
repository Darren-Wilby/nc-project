# Get the AWS Availability Zones in the current region
data "aws_availability_zones" "available" {}

# Create the VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.vpc_name

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

# Create the default security group for the VPC
resource "aws_default_security_group" "main" {
  vpc_id = module.vpc.vpc_id

  # Allow all inbound and outbound traffic (IPv4 and IPv6)
  ingress {
    protocol         = -1
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    self             = true
  }

  egress {
    protocol         = -1
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "lms-sg"
  }
}

# Create Private ECRs for Frontend and Backend
resource "aws_ecr_repository" "frontend" {
  name                 = "react-frontend-ecr"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "java-backend-ecr"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Create an Amazon RDS PostgreSQL database instance
resource "aws_db_instance" "main" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "11.21"
  instance_class         = "db.t2.micro"
  identifier             = "lms-db"
  username               = "postgres"
  password               = "mysecretpassword"
  db_name                = "db1"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_default_security_group.main.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
}

# Create a DB subnet group for the RDS instance
resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group"
  subnet_ids = module.vpc.private_subnets[*]
}

# Define desired node group size for Amazon EKS
resource "null_resource" "update_desired_size" {
  # Depends on the completion of the EKS module
  depends_on = [module.eks.eks]

  # Define triggers to react when the `desired_size` variable changes
  triggers = {
    desired_size = var.desired_size
  }

  # Use local-exec provisioner to run a Bash command
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    # Update the desired size of the EKS node group using AWS CLI
    command = <<-EOT
      aws eks update-nodegroup-config \
        --cluster-name ${var.cluster_name} \
        --nodegroup-name ${element(split(":", module.eks.eks_managed_node_groups.one.node_group_id), 1)} \
        --scaling-config desiredSize=${var.desired_size}
    EOT
  }
}

# Create the Amazon EKS cluster using the terraform-aws-modules/eks/aws module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.2"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets[*]
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  # Create a managed node group
  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
}
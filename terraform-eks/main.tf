provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "bilarn_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "bilarn-vpc"
  }
}

resource "aws_subnet" "bilarn_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.bilarn_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.bilarn_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "bilarn-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "bilarn_igw" {
  vpc_id = aws_vpc.bilarn_vpc.id

  tags = {
    Name = "bilarn-igw"
  }
}

resource "aws_route_table" "bilarn_route_table" {
  vpc_id = aws_vpc.bilarn_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bilarn_igw.id
  }

  tags = {
    Name = "bilarn-route-table"
  }
}

resource "aws_route_table_association" "a" {
  count          = 2
  subnet_id      = aws_subnet.bilarn_subnet[count.index].id
  route_table_id = aws_route_table.bilarn_route_table.id
}

resource "aws_security_group" "bilarn_cluster_sg" {
  vpc_id = aws_vpc.bilarn_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bilarn-cluster-sg"
  }
}

resource "aws_security_group" "bilarn_node_sg" {
  vpc_id = aws_vpc.bilarn_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bilarn-node-sg"
  }
}

resource "aws_security_group" "setup_server_sg" {
  vpc_id = aws_vpc.bilarn_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"] # Replace with your IP for SSH
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "setup-server-sg"
  }
}

resource "aws_eks_cluster" "bilarn" {
  name     = "bilarn-cluster"
  role_arn = aws_iam_role.bilarn_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.bilarn_subnet[*].id
    security_group_ids = [aws_security_group.bilarn_cluster_sg.id]
  }
}

resource "aws_eks_node_group" "bilarn" {
  cluster_name    = aws_eks_cluster.bilarn.name
  node_group_name = "bilarn-node-group"
  node_role_arn   = aws_iam_role.bilarn_node_group_role.arn
  subnet_ids      = aws_subnet.bilarn_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 2
  }

  instance_types = ["t2.medium"]

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.bilarn_node_sg.id]
  }
}

resource "aws_iam_role" "bilarn_cluster_role" {
  name = "bilarn-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bilarn_cluster_role_policy" {
  role       = aws_iam_role.bilarn_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "bilarn_node_group_role" {
  name = "bilarn-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bilarn_node_group_role_policy" {
  role       = aws_iam_role.bilarn_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "bilarn_node_group_cni_policy" {
  role       = aws_iam_role.bilarn_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "bilarn_node_group_registry_policy" {
  role       = aws_iam_role.bilarn_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_instance" "setup_server" {
  ami             = "ami-xxxxxxxx" # Use a valid Ubuntu AMI for your region
  instance_type   = "t3.medium"
  subnet_id       = aws_subnet.bilarn_subnet[0].id
  key_name        = var.ssh_key_name
  security_groups = [aws_security_group.setup_server_sg.id]

  user_data = file("${path.module}/installation-script/installscript.sh")

  tags = {
    Name = "setup-server"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_eip" "node_master_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.node_master_interface.id
  associate_with_private_ip = var.master_private_ip
}

resource "aws_network_interface" "node_master_interface" {
  subnet_id       = var.master_subnet
  private_ips     = [var.master_private_ip]
  security_groups = [aws_security_group.kubernetes_node.id, aws_security_group.kubernetes_master.id]

  tags = {
    Name = "Node Master Network Interface"
  }
}

resource "aws_key_pair" "kubernetes_ssh_key" {
  key_name   = "kubernetes_ssh_key"
  public_key = var.ssh_key
}

resource "aws_security_group" "kubernetes_node" {
  name        = "kubernetes_node"
  description = "Grupo de seguranca para nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Kubernetes Node SG"
  }
}

resource "aws_security_group" "kubernetes_master" {
  name        = "kubernetes_master"
  description = "Grupo de seguranca para master"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Kubernetes Node SG"
  }
}

resource "aws_instance" "node_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  availability_zone = var.master_zone
  key_name          = aws_key_pair.kubernetes_ssh_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.node_master_interface.id
    device_index         = 0
  }

  tags = {
    Name    = var.master_name
    project = "magma"
    budget  = "kubernetes"
  }
}

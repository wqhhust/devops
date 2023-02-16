provider "aws" {
  region = "us-east-2"
}

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

  owners = ["099720109477"] # Canonical
}

resource "aws_iam_role_policy_attachment" "code_commit_write" {
  # Just for test, so used a powerful policy, in produciton need to use least privilege
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
  role = aws_iam_role.ec2_web_server_role.name
}

resource "aws_iam_role_policy_attachment" "push_to_ecr" {
  # Just for test, so used a powerful policy, in produciton need to use least privilege
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role = aws_iam_role.ec2_web_server_role.name
}

resource "aws_iam_role" "ec2_web_server_role" {
  assume_role_policy = file("./assumerolepolicy.json")
  name               = "ServiceRoleForEC2WithCodeCommit"
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_instance_profile"
  # This is the aws_iam_role the policy will attach to
  role = aws_iam_role.ec2_web_server_role.name
}


# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "daniel_key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Save file
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
  file_permission="600"
}

resource "aws_security_group" "daniel_sg" {
  name = "daniel_sg_demo"
  dynamic "ingress" {
    iterator = port
    for_each = local.open_port_number_list
    content {
       from_port = port.value
       to_port = port.value
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "daniel_key"
  vpc_security_group_ids = [aws_security_group.daniel_sg.id]
  user_data              = file("install_jenkins.sh")
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name

  tags = {
    Name = "jenkins"
  }
}


resource "local_file" "inventory_for_ansible" {
  filename = "inventory"
  content  = templatefile("inventory_template", {
     ip = aws_instance.jenkins.public_ip
  })
  file_permission="600"
}

resource "local_file" "init_jenkins_groovy" {
  filename = "jenkins_config/init_jenkins.groovy"
  content  = templatefile("jenkins_config/init_jenkins.groovy.template", {
    jenkins_admin_password = var.jenkins_admin_password
    jenkins_testuser_password = var.jenkins_testuser_password
  })
}

resource "local_file" "ssh_to_jenkins" {
  filename = "ssh_to_jenkins"
  content  = "ssh -i daniel_key.pem  -oStrictHostKeyChecking=no ubuntu@${aws_instance.jenkins.public_ip}"
  file_permission="700"
}


resource "aws_key_pair" "daniel_key" {
  key_name   = "terraform_key"
  public_key = file("~/.ssh/aws_terraform_rsa.pub")
}

resource "aws_security_group" "daniel_sg" {
  name = "daniel_sg_demo"
  ingress {
    from_port   = var.port_number
    to_port     = var.port_number
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "asg_template" {
  image_id               = "ami-0fb653ca2d3203ac1"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.daniel_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

data aws_availability_zones "zones" {
  state = "available"
}
resource "aws_autoscaling_group" "asg" {
  availability_zones = data.aws_availability_zones.zones.names[*]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1

  protect_from_scale_in = true
  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

provider "aws" {
  region = "us-east-2"
}

variable route53_hosted_zone_name {
  type = string
  default = "default_zone.com"
}

variable web_servers_list {
  type = list
  default = ["primary", "replica_1", "replica_2"]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# resource "aws_route53_zone" "zone" {
#   name = "daniel.com"
# }


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
resource "aws_instance" "webs" {
  for_each = toset(var.web_servers_list)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  user_data = <<EOF
#!/bin/bash
apt update -y
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
echo "<h1>${each.value}</h1>" > /var/www/html/index.html
EOF

#  key_name               = "daniel_key"
  vpc_security_group_ids = [aws_security_group.daniel_sg.id]
#  iam_instance_profile   = aws_iam_instance_profile.test_profile.name

  tags = {
    Name = "web"
  }
}

 resource "aws_alb" "demo_alb" {
   name = "demo-alb"
   internal = false
   load_balancer_type = "application"
   security_groups = [aws_security_group.daniel_sg.id]
   subnets = data.aws_subnets.public.ids
 }

resource "aws_security_group" "daniel_sg" {
  name = "daniel_sg_demo"
  dynamic "ingress" {
    iterator = port
    for_each = [22,80,8080]
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

resource "aws_lb_target_group_attachment" "test" {
  count = length(var.web_servers_list)
  target_group_arn = aws_alb_target_group.group_1.arn
  target_id        = aws_instance.webs[count.index].id
  port             = 80
}


resource "aws_alb_target_group" "group_1" {
  name     = "terraform-alb-target-group-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/"
    port = 80
  }
}


resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.demo_alb.arn # "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.group_1.arn
    type             = "forward"
  }
}

# resource "aws_route53_record" "route53" {
#   name = "terraform.${var.route53_hosted_zone_name}"
#   type = "A"

#   zone_id = aws_route53_zone.zone.id

#   alias {
#     name                   = "${aws_alb.demo_alb.dns_name}"
#     zone_id                = "${aws_alb.demo_alb.zone_id}"
#     evaluate_target_health = true
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }


output subnets {
  value = [
    for v in data.aws_subnets.public.ids : v
  ]
}

output url {
  value = aws_instance.webs[*].public_id
}

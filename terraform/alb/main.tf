variable route53_hosted_zone_name {
  type = string
  default = "default_zone.com"
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

resource "aws_route53_zone" "zone" {
  name = "daniel.com"
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
    for_each = [80,8080]
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
    path = "/login"
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

resource "aws_route53_record" "route53" {
  name = "terraform.${var.route53_hosted_zone_name}"
  type = "A"

  zone_id = aws_route53_zone.zone.id

  alias {
    name                   = "${aws_alb.demo_alb.dns_name}"
    zone_id                = "${aws_alb.demo_alb.zone_id}"
    evaluate_target_health = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


output subnets {
  value = [
    for v in data.aws_subnets.public.ids : v
  ]
}

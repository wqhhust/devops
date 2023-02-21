data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example" {
  # required
  vpc_id            = aws_vpc.example.id

  # optional
  count = 2
  # need to enable public IP for it so that nodes inside it can join eks cluster
  # https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html
  map_public_ip_on_launch = true
  # must be in different AZ
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.example.cidr_block, 8, count.index)
}

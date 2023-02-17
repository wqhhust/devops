variable "port_number" {
  type    = number
  default = 8080
}


variable "jenkins_admin_password" {
  type = string
  default = "admin_password"
}


variable "jenkins_testuser_password" {
  type = string
  default = "test_password"
}

variable "github_url" {
  type = string
  default = "https://github.com/wqhhust/javatest.git"
}
variable "aws_ecr_url" {
  type = string
  default = "617815228888.dkr.ecr.us-east-1.amazonaws.com/danielsite"
}

variable "aws_codecommit_url" {
  type = string
  default = "617815228888.dkr.ecr.us-east-1.amazonaws.com/danielsite"
}

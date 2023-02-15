output "master_ip" {
  value       = aws_instance.jenkins.public_ip
  description = "the public IP of jenkins"
}


output "ssh_string" {
  value       = "ssh -i daniel_key.pem  -oStrictHostKeyChecking=no ubuntu@${aws_instance.jenkins.public_ip}"
  description = "string to connect to EC2"
}




output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "slave1_ip" {
  value = aws_instance.jenkins_slave1.public_ip
}

output "slave2_ip" {
  value = aws_instance.jenkins_slave2.public_ip
}

output "wildfly_ip" {
  value = aws_instance.wildfly.public_ip
}
output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_slave_ip" {
  value = aws_instance.jenkins_slave.public_ip
}

output "wildfly_ip" {
  value = aws_instance.wildfly_server.public_ip
}

output "jenkins_s3_bucket_name" {
  value = aws_s3_bucket.jenkins_home.bucket
}
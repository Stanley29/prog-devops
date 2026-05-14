resource "aws_s3_bucket" "jenkins_home" {
  bucket = var.jenkins_s3_bucket_name

  tags = {
    Name = "jenkins-home-backup-08"
  }
}
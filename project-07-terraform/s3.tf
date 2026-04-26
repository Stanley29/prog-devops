resource "aws_s3_bucket" "jenkins" {
  bucket        = "jenkins-backup-sergii"
  force_destroy = true
}

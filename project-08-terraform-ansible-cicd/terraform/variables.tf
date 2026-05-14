variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS key pair name"
  type        = string
  default     = "HrSolution_Key_Pair"
}

variable "jenkins_s3_bucket_name" {
  description = "S3 bucket name for JENKINS_HOME backup"
  type        = string
  default     = "jenkins-home-backup-bucket-08"
}
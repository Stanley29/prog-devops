resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]

  tags = {
    Name = "jenkins-master-08"
    Role = "jenkins_master"
  }
}
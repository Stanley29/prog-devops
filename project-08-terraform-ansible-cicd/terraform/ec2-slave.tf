resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_slave_sg.id]

  tags = {
    Name = "jenkins-slave-08"
    Role = "jenkins_slave"
  }
}
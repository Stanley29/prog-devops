resource "aws_instance" "jenkins_slave1" {
  ami = data.aws_ami.ubuntu_2204.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_slaves_sg.id]

  user_data = file("/../slave-setup.sh")

  tags = {
    Name = "jenkins-slave-1"
  }
}
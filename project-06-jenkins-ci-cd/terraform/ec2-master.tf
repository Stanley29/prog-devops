data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "jenkins_master" {
  ami = data.aws_ami.ubuntu_2204.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]

  user_data = file("/../jenkins-install.sh")

  tags = {
    Name = "jenkins-master"
  }
}
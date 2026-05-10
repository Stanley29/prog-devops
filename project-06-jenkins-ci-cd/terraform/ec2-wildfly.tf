resource "aws_instance" "wildfly" {
  ami = data.aws_ami.ubuntu_2204.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.wildfly_sg.id]

  user_data = file("/../wildfly-install.sh")

  tags = {
    Name = "wildfly-server"
  }
}
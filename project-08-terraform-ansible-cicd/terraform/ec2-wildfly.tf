resource "aws_instance" "wildfly_server" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.wildfly_sg.id]

  tags = {
    Name = "wildfly-server-08"
    Role = "wildfly_server"
  }
}
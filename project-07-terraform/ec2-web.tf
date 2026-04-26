resource "aws_instance" "web" {
  ami           = "ami-0028809abe98af413"
  instance_type = var.instance_type

  subnet_id = local.default_subnet_id

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  key_name = "HrSolution_Key_Pair"

  tags = {
    Name = "web"
  }
}

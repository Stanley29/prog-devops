resource "aws_instance" "master" {
  ami           = "ami-0028809abe98af413"
  instance_type = var.instance_type

  subnet_id = local.default_subnet_id

  vpc_security_group_ids = [
    aws_security_group.master_sg.id
  ]

  key_name = "HrSolution_Key_Pair"

  user_data = file("user-data/master.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "master"
  }
}

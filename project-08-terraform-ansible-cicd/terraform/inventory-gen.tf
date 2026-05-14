locals {
  inventory_content = templatefile("${path.module}/templates/inventory.tpl", {
    jenkins_master_ip = aws_instance.jenkins_master.public_ip
    jenkins_slave_ip  = aws_instance.jenkins_slave.public_ip
    wildfly_ip        = aws_instance.wildfly_server.public_ip
  })
}

resource "local_file" "ansible_inventory" {
  content  = local.inventory_content
  filename = "${path.module}/generated/inventory.ini"
}


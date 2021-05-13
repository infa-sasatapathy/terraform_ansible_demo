provider "aws" {
    region = "us-east-1"
    profile = "saumik"
}

resource "aws_instance" "ec2" {
    ami = "ami-0d5eff06f840b45e9"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    security_groups = [ "Jenkins-sg" ]
    key_name = "cka"

    tags = {
        Name = "Master Node"
    }

connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("C:/HashiCorp/Terraform/terraform/proj1/cka.pem")
    host = aws_instance.ec2.public_ip
}

  provisioner "file" {
    source      = "webserver.yaml"
    destination = "/home/ec2-user/webserver.yaml"
  }

  provisioner "file" {
    source      = "ansible.cfg"
    destination = "/home/ec2-user/ansible.cfg"
  }

  provisioner "file" {
    source      = "cka.pem"
    destination = "/home/ec2-user/cka.pem"
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/home/ec2-user/index.html"
  }

  provisioner "file" {
    content     = aws_instance.node.private_ip
    destination = "/home/ec2-user/inventory"
  }

provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
        "sudo amazon-linux-extras install ansible2 -y",
    ]
 }

provisioner "remote-exec" {
   inline = [
    "cd /home/ec2-user",
    "sudo chmod 400 cka.pem",
    "ansible-playbook webserver.yaml  --private-key cka.pem"
   ]
 }

}

resource "aws_instance" "node" {
    ami = "ami-0d5eff06f840b45e9"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    security_groups = [ "Jenkins-sg" ]
    key_name = "cka"

    tags = {
        Name = "Worker Server"
    }

connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("C:/HashiCorp/Terraform/terraform/proj1/cka.pem")
    host = aws_instance.node.public_ip
 }

}
output "Web_Server_IP" {
   value = aws_instance.node.public_ip
  }
#
# tools instance to run bash/ansible
#

##### We need the kubeconf an authenticator yaml file

resource "local_file" "configmap" {
    content     = "${local.config_map_aws_auth}"
    filename = "generated-configmap.yaml"
}

resource "local_file" "kubeconf" {
    content     = "${local.kubeconfig}"
    filename = "generated-kube.conf"
}

resource "null_resource" "kubeconfigmap" {
  provisioner "local-exec" {
    command = "curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/darwin/amd64/kubectl"   
  }

    provisioner "local-exec" {
    command = "chmod +x kubectl"   
  }

      provisioner "local-exec" {
    command = "./kubectl --kubeconfig=${local_file.kubeconf.filename} apply -f ${local_file.configmap.filename}"   
  }
}

#####

resource "aws_instance" "bastion" {
  ami           = "${var.ec2_ami_id}"
  instance_type = "t2.large"
  key_name = "${var.ec2_key}"
  vpc_security_group_ids =["${aws_security_group.bastion.id}"]
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.sbnet.*.id[0]}"
  iam_instance_profile ="${var.capstan_bastion_role_name}"

 connection {
    user        = "${var.ec2_ssh_user}"
    private_key = "${file(var.ec2_key_file)}"
    agent       = false
  }

  provisioner "file" {
    source      = "${local_file.kubeconf.filename}"
    destination = "/home/${var.ec2_ssh_user}/${local_file.kubeconf.filename}"
  }

  provisioner "file" {
    source      = "${local_file.configmap.filename}"
    destination = "/home/${var.ec2_ssh_user}/${local_file.configmap.filename}"
  }

    provisioner "file" {
    source      = "../scripts/"
    destination = "/home/${var.ec2_ssh_user}"
  }

  provisioner "file" {
    source      = "../../pipelines"
    destination = "/home/${var.ec2_ssh_user}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ec2_ssh_user}/*.sh",
      "/home/${var.ec2_ssh_user}/instance_setup.sh"
    ]
  }


    tags = "${
    map(
     "Name", "${var.gen_solution_name}-tools",
     "Usage", "kubernetes.io/cluster/${var.gen_solution_name}",
    )
  }"

  
  
}
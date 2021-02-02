data "template_file" "install_mysql" {
  template = file("${path.module}/scripts/install_mysql.sh")

  vars = {
    mysql_version       = var.mysql_version
    admin_username      = var.admin_username
    admin_password      = var.admin_password
  }  
}

resource "oci_core_instance" "MySQLinstance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  shape               = var.mysql_shape
  display_name        = var.display_name

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = false
    hostname_label   = var.display_name
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = base64encode(data.template_file.install_mysql.rendered)
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

data "oci_core_vnic_attachments" "MySQLinstance_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  instance_id         = oci_core_instance.MySQLinstance.id
}

data "oci_core_vnic" "MySQLinstance_vnic1" {
  vnic_id = data.oci_core_vnic_attachments.MySQLinstance_vnics.vnic_attachments[0]["vnic_id"]
}

/*
resource "null_resource" "MySQL_provisioner" {
  depends_on = [oci_core_instance.MySQLinstance]

  provisioner "file" {
    content     = data.template_file.install_mysql.rendered
    destination = "~/install_mysql.sh"

    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.MySQLinstance_vnic1.private_ip_address 
      user        = "opc"
      private_key = var.ssh_private_key
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = var.bastion_public_ip_address
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = var.ssh_private_key
    }
  }

   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.MySQLinstance_vnic1.private_ip_address 
      user        = "opc"
      private_key = var.ssh_private_key
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = var.bastion_public_ip_address
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = var.ssh_private_key
    }
   
    inline = [       
       "chmod +x ~/install_mysql.sh",
       "sudo ~/install_mysql.sh",
    ]

   }

}
*/

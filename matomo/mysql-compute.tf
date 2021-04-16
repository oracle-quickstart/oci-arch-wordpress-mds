## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "install_mysql" {
  template = file("${path.module}/scripts/install_mysql.sh")

  vars = {
    mysql_version       = var.mysql_version
    admin_username      = var.admin_username
    admin_password      = var.admin_password
  }  
}

resource "oci_core_instance" "MySQLinstance" {
  availability_domain = var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  shape               = var.node_shape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.node_flex_shape_memory
      ocpus = var.node_flex_shape_ocpus
    }
  }

  display_name        = "MySQLInstance"

  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    assign_public_ip = false
    hostname_label   = "mysql"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = data.template_cloudinit_config.cloud_init.rendered
  }

  source_details {
    source_id   = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")   
    source_type = "image"
  }

  #provisioner "local-exec" {
  #  command = "sleep 120"
  #}

  defined_tags         = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

data "oci_core_vnic_attachments" "MySQLinstance_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availablity_domain_name
  instance_id         = oci_core_instance.MySQLinstance.id
}

data "oci_core_vnic" "MySQLinstance_vnic1" {
  vnic_id = data.oci_core_vnic_attachments.MySQLinstance_vnics.vnic_attachments[0]["vnic_id"]
}


resource "null_resource" "MySQL_provisioner" {
  depends_on = [oci_core_instance.MySQLinstance, oci_core_instance.WordPress]

  provisioner "file" {
    content     = data.template_file.install_mysql.rendered
    destination = "~/install_mysql.sh"

    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.MySQLinstance_vnic1.private_ip_address 
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_public_ip.WordPress_public_ip.ip_address
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = data.oci_core_vnic.MySQLinstance_vnic1.private_ip_address 
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
      bastion_host = oci_core_public_ip.WordPress_public_ip.ip_address
      bastion_port = "22"
      bastion_user = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
   
    inline = [       
       "chmod +x ~/install_mysql.sh",
       "sudo ~/install_mysql.sh",
    ]

   }

}


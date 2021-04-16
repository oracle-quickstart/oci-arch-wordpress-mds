## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

## DATASOURCE
# Init Script Files
data "template_file" "install_php" {
  template = file("${path.module}/scripts/install_php74.sh")

  vars = {
    mysql_version         = var.mysql_version
    user                  = "opc"
  }
}

data "template_file" "install_wp" {
  template = file("${path.module}/scripts/install_wp.sh")
}

data "template_file" "configure_local_security" {
  template = file("${path.module}/scripts/configure_local_security.sh")
}

data "template_file" "create_wp_db" {
  template = file("${path.module}/scripts/create_wp_db.sh")

  vars = {
    admin_password = var.admin_password
    admin_username = var.admin_username
    wp_name        = var.wp_name
    wp_password    = var.wp_password
    wp_schema      = var.wp_schema
    mds_ip         = data.oci_core_vnic.MySQLinstance_vnic1.private_ip_address
  }
}

locals {
  php_script      = "~/install_php74.sh"
  wp_script       = "~/install_wp.sh"
  security_script = "~/configure_local_security.sh"
  create_wp_db    = "~/create_wp_db.sh"
  setup_wp        = "~/setup_wp.sh"
}

resource "oci_core_instance" "WordPress" {
  availability_domain = var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "WordPress"
  shape               = var.node_shape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.node_flex_shape_memory
      ocpus = var.node_flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    display_name     = "WordPress"
    assign_public_ip = false
    hostname_label   = "wordpress"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = data.template_cloudinit_config.cloud_init.rendered
  }

  source_details {
    source_id   = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
    source_type = "image"
  }

  defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

data "oci_core_vnic_attachments" "WordPress_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availablity_domain_name
  instance_id         = oci_core_instance.WordPress.id
}

data "oci_core_vnic" "WordPress_vnic1" {
  vnic_id = data.oci_core_vnic_attachments.WordPress_vnics.vnic_attachments[0]["vnic_id"]
}

data "oci_core_private_ips" "WordPress_private_ips1" {
  vnic_id = data.oci_core_vnic.WordPress_vnic1.id
}

resource "oci_core_public_ip" "WordPress_public_ip" {
  compartment_id = var.compartment_ocid
  display_name   = "WordPress_public_ip"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.WordPress_private_ips1.private_ips[0]["id"]
  defined_tags   = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

data "template_file" "setup_wp" {
  template = file("${path.module}/scripts/setup_wp.sh")

  vars = {
    wp_name             = var.wp_name
    wp_password         = var.wp_password
    wp_schema           = var.wp_schema
    mds_ip              = data.oci_core_vnic.MySQLinstance_vnic1.private_ip_address
    wp_site_url         = oci_core_public_ip.WordPress_public_ip.ip_address
    wp_site_title       = var.wp_site_title
    wp_site_admin_user  = var.wp_site_admin_user
    wp_site_admin_pass  = var.wp_site_admin_pass
    wp_site_admin_email = var.wp_site_admin_email
    wp_plugins          = join(" ", split(",", var.wp_plugins))
    wp_themes           = join(" ", split(",", var.wp_themes))
  }  
}

resource "null_resource" "WordPress_provisioner" {
  depends_on = [oci_core_instance.WordPress, oci_core_public_ip.WordPress_public_ip, null_resource.MySQL_provisioner]

  provisioner "file" {
    content     = data.template_file.install_php.rendered
    destination = local.php_script

    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem

    }
  }

  provisioner "file" {
    content     = data.template_file.install_wp.rendered
    destination = local.wp_script

    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem

    }
  }

  provisioner "file" {
    content     = data.template_file.configure_local_security.rendered
    destination = local.security_script

    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem

    }
  }

 provisioner "file" {
    content     = data.template_file.create_wp_db.rendered
    destination = local.create_wp_db

    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem

    }
  }

  provisioner "file" {
    content     = data.template_file.setup_wp.rendered
    destination = local.setup_wp

    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem

    }
  }

   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem

    }
   
    inline = [
       "chmod +x ${local.php_script}",
       "sudo ${local.php_script}",
       "chmod +x ${local.wp_script}",
       "sudo ${local.wp_script}",
       "chmod +x ${local.security_script}",
       "sudo ${local.security_script}",
       "chmod +x ${local.create_wp_db}",
       "sudo ${local.create_wp_db}",
       "chmod +x ${local.setup_wp}",
       "sudo ${local.setup_wp}"
    ]

   }

}
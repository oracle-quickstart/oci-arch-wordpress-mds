## DATASOURCE
# Init Script Files
data "template_file" "install_php" {
  template = file("${path.module}/scripts/install_php74.sh")

  vars = {
    mysql_version         = "${var.mysql_version}",
    user                  = "${var.vm_user}"
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
    mds_ip         = var.mds_ip
  }
}



locals {
  php_script      = "~/install_php74.sh"
  wp_script       = "~/install_wp.sh"
  security_script = "~/configure_local_security.sh"
  create_wp_db    = "~/create_wp_db.sh"
}

resource "oci_core_instance" "WordPress" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.display_name}"
  shape               = var.shape

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${var.label_prefix}${var.display_name}"
    assign_public_ip = var.assign_public_ip
    hostname_label   = var.display_name
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "file" {
    content     = data.template_file.install_php.rendered
    destination = local.php_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.install_wp.rendered
    destination = local.wp_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.configure_local_security.rendered
    destination = local.security_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

 provisioner "file" {
    content     = data.template_file.create_wp_db.rendered
    destination = local.create_wp_db

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }


   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
   
    inline = [
       "chmod +x ${local.php_script}",
       "sudo ${local.php_script}",
       "chmod +x ${local.wp_script}",
       "sudo ${local.wp_script}",
       "chmod +x ${local.security_script}",
       "sudo ${local.security_script}",
       "chmod +x ${local.create_wp_db}",
       "sudo ${local.create_wp_db}"
    ]

   }

  timeouts {
    create = "10m"

  }
}
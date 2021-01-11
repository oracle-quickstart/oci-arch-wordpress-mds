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
  setup_wp        = "~/setup_wp.sh"
}

resource "oci_core_instance" "WordPress" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.display_name}"
  shape               = var.shape

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${var.label_prefix}${var.display_name}"
    assign_public_ip = false
    hostname_label   = var.display_name
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }
}

data "oci_core_vnic_attachments" "WordPress_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
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
}

data "template_file" "setup_wp" {
  template = file("${path.module}/scripts/setup_wp.sh")

  vars = {
    wp_name             = var.wp_name
    wp_password         = var.wp_password
    wp_schema           = var.wp_schema
    mds_ip              = var.mds_ip
    wp_site_url         = oci_core_public_ip.WordPress_public_ip.ip_address
    wp_site_title       = var.wp_site_title
    wp_site_admin_user  = var.wp_site_admin_user
    wp_site_admin_pass  = var.wp_site_admin_pass
    wp_site_admin_email = var.wp_site_admin_email
    wp_plugins          = join(" ", var.wp_plugins)
    wp_themes           = join(" ", var.wp_themes)
  }  
}

resource "null_resource" "WordPress_provisioner" {
  depends_on = [oci_core_instance.WordPress, oci_core_public_ip.WordPress_public_ip]

  provisioner "file" {
    content     = data.template_file.install_php.rendered
    destination = local.php_script

    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
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
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
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
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
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
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

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
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
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
       "sudo ${local.create_wp_db}",
       "chmod +x ${local.setup_wp}",
       "sudo ${local.setup_wp}"
    ]

   }

}
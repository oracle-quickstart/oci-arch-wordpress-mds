# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
data "template_file" "wordpress-docker-compose" {
  template = file("${path.module}/scripts/wordpress.yaml")

  vars = {
    public_key_openssh  = tls_private_key.public_private_key_pair.public_key_openssh,
    mysql_root_password = random_password.mysql_root_password.result,
    wp_schema           = var.wp_schema,
    wp_db_user          = var.wp_db_user,
    wp_db_password      = random_password.wp_db_password.result,
    wp_site_url         = oci_core_public_ip.WordPress_public_ip.ip_address,
    wp_admin_user       = var.wp_admin_user,
    wp_admin_password   = var.wp_admin_password
  }
}


resource "oci_core_instance" "WordPress" {
  availability_domain = local.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "wordpress"
  shape               = local.instance_shape

  dynamic "shape_config" {
    for_each = local.is_flexible_instance_shape ? [1] : []
    content {
      ocpus         = var.instance_ocpus
      memory_in_gbs = var.instance_shape_config_memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    display_name     = "primaryvnic"
    assign_public_ip = false
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.InstanceImageOCID.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.generate_public_ssh_key ? tls_private_key.public_private_key_pair.public_key_openssh : join("\n", [var.public_ssh_key, tls_private_key.public_private_key_pair.public_key_openssh])
    user_data           = base64encode(templatefile("./scripts/setup-docker.yaml", {}))
  }

}

data "oci_core_vnic_attachments" "WordPress_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain_name
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

resource "null_resource" "WordPress_provisioner" {
  depends_on = [oci_core_instance.WordPress, oci_core_public_ip.WordPress_public_ip]

  provisioner "file" {
    content     = data.template_file.wordpress-docker-compose.rendered
    destination = "/home/opc/wordpress.yaml"

    connection {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem

    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip.ip_address
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem

    }

    inline = [
      "while [ ! -f /tmp/cloud-init-complete ]; do sleep 2; done",
      "docker-compose -f /home/opc/wordpress.yaml up -d"
    ]

  }
}

resource "random_password" "mysql_root_password" {
  length           = 16
  special          = true
  override_special = "&-_"
}

resource "random_password" "wp_db_password" {
  length           = 16
  special          = true
  override_special = "&-_"
}

locals {
  availability_domain_name   = var.availability_domain_name != null ? var.availability_domain_name : data.oci_identity_availability_domains.ADs.availability_domains[0].name
  instance_shape             = var.instance_shape
  compute_flexible_shapes    = ["VM.Standard.E3.Flex","VM.Standard.E4.Flex"]
  is_flexible_instance_shape = contains(local.compute_flexible_shapes, local.instance_shape)
}

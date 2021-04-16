## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "install_matomo" {
  template = file("${path.module}/scripts/install_matomo.sh")

  vars = {
    admin_password   = var.admin_password
    admin_username   = var.admin_username
    matomo_username  = var.matomo_username
    matomo_password  = var.matomo_password
    matomo_schema    = var.matomo_schema
    mysql_compute_ip = data.oci_core_vnic.MySQLinstance_vnic1.private_ip_address 
    mysql_version    = var.mysql_version
    user             = "opc"
  }
}

resource "oci_core_instance" "MatomoInstance" {
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
 
  display_name        = "MatomoInstance"

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = false
    hostname_label   = "matomo"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = data.template_cloudinit_config.cloud_init.rendered
  }

  source_details {
    source_id   = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
    source_type = "image"
  }

  defined_tags         = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
 # provisioner "local-exec" {
 #   command = "sleep 60"
 # }
}

data "oci_core_vnic_attachments" "MatomoInstance_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availablity_domain_name
  instance_id         = oci_core_instance.MatomoInstance.id
}

data "oci_core_vnic" "MatomoInstance_vnic1" {
  vnic_id = data.oci_core_vnic_attachments.MatomoInstance_vnics.vnic_attachments[0]["vnic_id"]
}

data "oci_core_private_ips" "MatomoInstance_private_ips1" {
  vnic_id = data.oci_core_vnic.MatomoInstance_vnic1.id
}

resource "oci_core_public_ip" "MatomoInstance_public_ip" {
  compartment_id = var.compartment_ocid
  display_name   = "MatomoInstance_public_ip"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.MatomoInstance_private_ips1.private_ips[0]["id"]
}

resource "null_resource" "MatomoInstance_provisioner" {
  depends_on = [oci_core_instance.MatomoInstance, null_resource.MySQL_provisioner, null_resource.WordPress_provisioner]

  provisioner "file" {
    content     = data.template_file.install_matomo.rendered
    destination = "~/install_matomo.sh"

    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.MatomoInstance_public_ip.ip_address
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
  }

   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.MatomoInstance_public_ip.ip_address
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
   
    inline = [       
       "chmod +x ~/install_matomo.sh",
       "sudo ~/install_matomo.sh",
    ]

   }

}


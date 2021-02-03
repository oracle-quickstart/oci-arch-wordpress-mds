data "template_file" "install_matomo" {
  template = file("${path.module}/scripts/install_matomo.sh")

  vars = {
    admin_password   = var.admin_password
    admin_username   = var.admin_username
    matomo_username  = var.matomo_username
    matomo_password  = var.matomo_password
    matomo_schema    = var.matomo_schema
    mysql_compute_ip = var.mysql_compute_ip
    mysql_version    = var.mysql_version
    user             = var.vm_user
  }
}

resource "oci_core_instance" "MatomoInstance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  shape               = var.matomo_shape
  display_name        = var.display_name

  create_vnic_details {
    subnet_id        = var.subnet_id
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

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

data "oci_core_vnic_attachments" "MatomoInstance_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
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
  depends_on = [oci_core_instance.MatomoInstance]

  provisioner "file" {
    content     = data.template_file.install_matomo.rendered
    destination = "~/install_matomo.sh"

    connection  {
      type        = "ssh"
      host        = oci_core_public_ip.MatomoInstance_public_ip.ip_address
      user        = "opc"
      private_key = var.ssh_private_key
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
      private_key = var.ssh_private_key
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


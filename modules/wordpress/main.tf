## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "tls_private_key" "public_private_key_pair" {
  algorithm = "RSA"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "install_php" {
  template = file("${path.module}/scripts/install_php74.sh")

  vars = {
    mysql_version = var.mysql_version
    user          = var.vm_user
  }
}

data "template_file" "setup_fss" {
  template = file("${path.module}/scripts/setup_fss.sh")

  vars = {
    wp_shared_working_dir = var.wp_shared_working_dir
    mt_ip_address         = local.mt_ip_address
    use_shared_storage    = tostring(var.use_shared_storage)
  }
}

data "template_file" "install_wp" {
  template = file("${path.module}/scripts/install_wp.sh")

  vars = {
    wp_working_dir = var.wp_working_dir
  }
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

data "template_file" "key_script" {
  template = file("${path.module}/scripts/sshkey.tpl")
  vars = {
    ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.key_script.rendered
  }
}

locals {
  php_script      = "~/install_php74.sh"
  wp_script       = "~/install_wp.sh"
  security_script = "~/configure_local_security.sh"
  create_wp_db    = "~/create_wp_db.sh"
  setup_wp        = "~/setup_wp.sh"
  setup_fss       = "~/setup_fss.sh"
  htaccess        = "~/htaccess"
}

data "oci_core_subnet" "wp_subnet_ds" {
  count     = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0
  subnet_id = var.wp_subnet_id
}


# FSS NSG
resource "oci_core_network_security_group" "WordPressFSSSecurityGroup" {
  count          = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "WordPressFSSSecurityGroup"
  vcn_id         = var.vcn_id
}

# FSS NSG Ingress TCP Rules
resource "oci_core_network_security_group_security_rule" "WordPressFSSSecurityIngressTCPGroupRules1" {
  count = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0

  network_security_group_id = oci_core_network_security_group.WordPressFSSSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = data.oci_core_subnet.wp_subnet_ds[0].cidr_block
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 111
      min = 111
    }
  }
}

# FSS NSG Ingress TCP Rules
resource "oci_core_network_security_group_security_rule" "WordPressFSSSecurityIngressTCPGroupRules2" {
  count = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0

  network_security_group_id = oci_core_network_security_group.WordPressFSSSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = data.oci_core_subnet.wp_subnet_ds[0].cidr_block
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 2050
      min = 2048
    }
  }
}

# FSS NSG Ingress UDP Rules
resource "oci_core_network_security_group_security_rule" "WordPressFSSSecurityIngressUDPGroupRules1" {
  count = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0

  network_security_group_id = oci_core_network_security_group.WordPressFSSSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "17"
  source                    = data.oci_core_subnet.wp_subnet_ds[0].cidr_block
  source_type               = "CIDR_BLOCK"

  udp_options {
    destination_port_range {
      max = 111
      min = 111
    }
  }
}

# FSS NSG Ingress UDP Rules
resource "oci_core_network_security_group_security_rule" "WordPressFSSSecurityIngressUDPGroupRules2" {
  count = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0

  network_security_group_id = oci_core_network_security_group.WordPressFSSSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "17"
  source                    = data.oci_core_subnet.wp_subnet_ds[0].cidr_block
  source_type               = "CIDR_BLOCK"

  udp_options {
    destination_port_range {
      max = 2048
      min = 2048
    }
  }
}


# FSS NSG Egress TCP Rules
resource "oci_core_network_security_group_security_rule" "WordPressFSSSecurityEgressTCPGroupRules1" {
  count = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0

  network_security_group_id = oci_core_network_security_group.WordPressFSSSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = data.oci_core_subnet.wp_subnet_ds[0].cidr_block
  destination_type          = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 111
      min = 111
    }
  }
}

# FSS NSG Egress TCP Rules
resource "oci_core_network_security_group_security_rule" "WordPressFSSSecurityEgressTCPGroupRules2" {
  count = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0

  network_security_group_id = oci_core_network_security_group.WordPressFSSSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = data.oci_core_subnet.wp_subnet_ds[0].cidr_block
  destination_type          = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 2050
      min = 2048
    }
  }
}


# FSS NSG Egress UDP Rules
resource "oci_core_network_security_group_security_rule" "WordPressFSSSecurityEgressUDPGroupRules1" {
  count = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0

  network_security_group_id = oci_core_network_security_group.WordPressFSSSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "17"
  destination               = data.oci_core_subnet.wp_subnet_ds[0].cidr_block
  destination_type          = "CIDR_BLOCK"

  udp_options {
    destination_port_range {
      max = 111
      min = 111
    }
  }

}

# Mount Target

resource "oci_file_storage_mount_target" "WordPressMountTarget" {
  count               = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0
  availability_domain = var.availability_domain == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availability_domain
  compartment_id      = var.compartment_ocid
  subnet_id           = var.fss_subnet_id
  display_name        = "WordPressMountTarget"
  nsg_ids             = [oci_core_network_security_group.WordPressFSSSecurityGroup[0].id]
}

data "oci_core_private_ips" "ip_mount_WordPressMountTarget" {
  count     = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0
  subnet_id = oci_file_storage_mount_target.WordPressMountTarget[0].subnet_id

  filter {
    name   = "id"
    values = [oci_file_storage_mount_target.WordPressMountTarget[0].private_ip_ids[0]]
  }
}

locals {
  mt_ip_address = var.numberOfNodes > 1 && var.use_shared_storage ? data.oci_core_private_ips.ip_mount_WordPressMountTarget[0].private_ips[0].ip_address : ""
}


# Export Set

resource "oci_file_storage_export_set" "WordPressExportset" {
  count           = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0
  mount_target_id = oci_file_storage_mount_target.WordPressMountTarget[0].id
  display_name    = "WordPressExportset"
}

# FileSystem

resource "oci_file_storage_file_system" "WordPressFilesystem" {
  count               = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0
  availability_domain = var.availability_domain == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "WordPressFilesystem"
}

# Export

resource "oci_file_storage_export" "WordPressExport" {
  count          = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0
  export_set_id  = oci_file_storage_mount_target.WordPressMountTarget[0].export_set_id
  file_system_id = oci_file_storage_file_system.WordPressFilesystem[0].id
  path           = var.wp_shared_working_dir
}


resource "oci_core_instance" "WordPress" {
  availability_domain = var.availability_domain == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.display_name}1"
  shape               = var.shape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.flex_shape_memory
      ocpus         = var.flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id        = var.wp_subnet_id
    display_name     = "${var.label_prefix}${var.display_name}1"
    assign_public_ip = false
    hostname_label   = var.display_name
  }

  dynamic "agent_config" {
    for_each = var.numberOfNodes > 1 ? [1] : []
    content {
      are_all_plugins_disabled = false
      is_management_disabled   = false
      is_monitoring_disabled   = false
      plugins_config {
        desired_state = "ENABLED"
        name          = "Bastion"
      }
    }
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  defined_tags = var.defined_tags

  provisioner "local-exec" {
    command = "sleep 240"
  }
}

data "oci_core_vnic_attachments" "WordPress_vnics" {
  depends_on          = [oci_core_instance.WordPress]
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availability_domain
  instance_id         = oci_core_instance.WordPress.id
}

data "oci_core_vnic" "WordPress_vnic1" {
  depends_on = [oci_core_instance.WordPress]
  vnic_id    = data.oci_core_vnic_attachments.WordPress_vnics.vnic_attachments[0]["vnic_id"]
}

data "oci_core_private_ips" "WordPress_private_ips1" {
  depends_on = [oci_core_instance.WordPress]
  vnic_id    = data.oci_core_vnic.WordPress_vnic1.id
  #vnic_id   = oci_core_instance.WordPress.private_ip
  subnet_id = var.wp_subnet_id
}

resource "oci_core_public_ip" "WordPress_public_ip_for_single_node" {
  depends_on     = [oci_core_instance.WordPress]
  count          = var.numberOfNodes > 1 ? 0 : 1
  compartment_id = var.compartment_ocid
  display_name   = "WordPress_public_ip_for_single_node"
  lifetime       = "RESERVED"
  #  private_ip_id  = var.numberOfNodes == 1 ? data.oci_core_private_ips.WordPress_private_ips1.private_ips[0]["id"] : null
  private_ip_id = data.oci_core_private_ips.WordPress_private_ips1.private_ips[0]["id"]
  defined_tags  = var.defined_tags
}

resource "oci_core_public_ip" "WordPress_public_ip_for_multi_node" {
  count          = var.numberOfNodes > 1 ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "WordPress_public_ip_for_multi_node"
  lifetime       = "RESERVED"
  defined_tags   = var.defined_tags
}

data "template_file" "setup_wp" {
  template = file("${path.module}/scripts/setup_wp.sh")

  vars = {
    wp_name               = var.wp_name
    wp_password           = var.wp_password
    wp_schema             = var.wp_schema
    mds_ip                = var.mds_ip
    wp_site_url           = var.numberOfNodes > 1 ? oci_core_public_ip.WordPress_public_ip_for_multi_node[0].ip_address : oci_core_public_ip.WordPress_public_ip_for_single_node[0].ip_address
    wp_site_title         = var.wp_site_title
    wp_site_admin_user    = var.wp_site_admin_user
    wp_site_admin_pass    = var.wp_site_admin_pass
    wp_site_admin_email   = var.wp_site_admin_email
    wp_plugins            = join(" ", var.wp_plugins)
    wp_themes             = join(" ", var.wp_themes)
    wp_working_dir        = var.wp_working_dir
    wp_shared_working_dir = var.wp_shared_working_dir
    use_shared_storage    = var.numberOfNodes > 1 ? tostring(var.use_shared_storage) : tostring(false)
  }
}

resource "oci_core_instance" "bastion_instance" {
  count               = var.numberOfNodes > 1 && !var.use_bastion_service ? 1 : 0
  availability_domain = var.availability_domain == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}BastionVM"
  shape               = var.bastion_shape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.bastion_flex_shape_memory
      ocpus         = var.bastion_flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id        = var.bastion_subnet_id
    display_name     = "bastionvm"
    assign_public_ip = true
  }

  source_details {
    source_id   = var.bastion_image_id
    source_type = "image"
  }

  defined_tags = var.defined_tags

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }
}


resource "oci_bastion_bastion" "bastion-service" {
  count            = var.numberOfNodes > 1 && var.use_bastion_service ? 1 : 0
  bastion_type     = "STANDARD"
  compartment_id   = var.compartment_ocid
  target_subnet_id = var.wp_subnet_id
  #target_subnet_id             = var.bastion_subnet_id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  name                         = "BastionService4WP"
  max_session_ttl_in_seconds   = 10800
}

resource "oci_bastion_session" "ssh_via_bastion_service" {
  depends_on = [oci_core_instance.WordPress]
  count      = var.numberOfNodes > 1 && var.use_bastion_service ? 1 : 0
  bastion_id = oci_bastion_bastion.bastion-service[0].id

  key_details {
    public_key_content = tls_private_key.public_private_key_pair.public_key_openssh
  }

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = oci_core_instance.WordPress.id
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = oci_core_instance.WordPress.private_ip
  }

  display_name           = "ssh_via_bastion_service_to_wordpress1"
  key_type               = "PUB"
  session_ttl_in_seconds = 10800
}

resource "null_resource" "WordPress_provisioner_without_bastion" {
  count      = var.numberOfNodes > 1 ? 0 : 1
  depends_on = [oci_core_instance.WordPress, oci_core_public_ip.WordPress_public_ip_for_single_node]

  provisioner "file" {
    content     = data.template_file.install_php.rendered
    destination = local.php_script

    connection {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip_for_single_node[0].ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    source      = "${path.module}/scripts/htaccess"
    destination = local.htaccess

    connection {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip_for_single_node[0].ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    content     = data.template_file.install_wp.rendered
    destination = local.wp_script

    connection {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip_for_single_node[0].ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    content     = data.template_file.configure_local_security.rendered
    destination = local.security_script

    connection {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip_for_single_node[0].ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    content     = data.template_file.create_wp_db.rendered
    destination = local.create_wp_db

    connection {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip_for_single_node[0].ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    content     = data.template_file.setup_wp.rendered
    destination = local.setup_wp

    connection {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip_for_single_node[0].ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = oci_core_public_ip.WordPress_public_ip_for_single_node[0].ip_address
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
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

resource "null_resource" "WordPress_provisioner_with_bastion" {
  count = var.numberOfNodes > 1 ? 1 : 0
  depends_on = [oci_core_instance.WordPress,
    oci_core_network_security_group.WordPressFSSSecurityGroup,
    oci_core_network_security_group_security_rule.WordPressFSSSecurityIngressTCPGroupRules1,
    oci_core_network_security_group_security_rule.WordPressFSSSecurityIngressTCPGroupRules2,
    oci_core_network_security_group_security_rule.WordPressFSSSecurityIngressUDPGroupRules1,
    oci_core_network_security_group_security_rule.WordPressFSSSecurityIngressUDPGroupRules2,
    oci_core_network_security_group_security_rule.WordPressFSSSecurityEgressTCPGroupRules1,
    oci_core_network_security_group_security_rule.WordPressFSSSecurityEgressTCPGroupRules2,
    oci_core_network_security_group_security_rule.WordPressFSSSecurityEgressUDPGroupRules1,
    oci_file_storage_export.WordPressExport,
    oci_file_storage_file_system.WordPressFilesystem,
    oci_file_storage_export_set.WordPressExportset,
  oci_file_storage_mount_target.WordPressMountTarget]

  provisioner "file" {
    content     = data.template_file.install_php.rendered
    destination = local.php_script

    connection {
      type                = "ssh"
      host                = data.oci_core_vnic.WordPress_vnic1.private_ip_address
      agent               = false
      timeout             = "5m"
      user                = var.vm_user
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.vm_user
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    source      = "${path.module}/scripts/htaccess"
    destination = local.htaccess

    connection {
      type                = "ssh"
      host                = data.oci_core_vnic.WordPress_vnic1.private_ip_address
      agent               = false
      timeout             = "5m"
      user                = var.vm_user
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.vm_user
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    content     = data.template_file.install_wp.rendered
    destination = local.wp_script

    connection {
      type                = "ssh"
      host                = data.oci_core_vnic.WordPress_vnic1.private_ip_address
      agent               = false
      timeout             = "5m"
      user                = var.vm_user
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.vm_user
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    content     = data.template_file.configure_local_security.rendered
    destination = local.security_script

    connection {
      type                = "ssh"
      host                = data.oci_core_vnic.WordPress_vnic1.private_ip_address
      agent               = false
      timeout             = "5m"
      user                = var.vm_user
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.vm_user
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    content     = data.template_file.create_wp_db.rendered
    destination = local.create_wp_db

    connection {
      type                = "ssh"
      host                = data.oci_core_vnic.WordPress_vnic1.private_ip_address
      agent               = false
      timeout             = "5m"
      user                = var.vm_user
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.vm_user
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    content     = data.template_file.setup_fss.rendered
    destination = local.setup_fss

    connection {
      type                = "ssh"
      host                = data.oci_core_vnic.WordPress_vnic1.private_ip_address
      agent               = false
      timeout             = "5m"
      user                = var.vm_user
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.vm_user
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "file" {
    content     = data.template_file.setup_wp.rendered
    destination = local.setup_wp

    connection {
      type                = "ssh"
      host                = data.oci_core_vnic.WordPress_vnic1.private_ip_address
      agent               = false
      timeout             = "5m"
      user                = var.vm_user
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.vm_user
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      host                = data.oci_core_vnic.WordPress_vnic1.private_ip_address
      agent               = false
      timeout             = "5m"
      user                = var.vm_user
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.bastion_service_region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[0].id : var.vm_user
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
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
      "chmod +x ${local.setup_fss}",
      "sudo ${local.setup_fss}",
      "chmod +x ${local.setup_wp}",
      "sudo ${local.setup_wp}"
    ]

  }

}

# Create WordPressImage

resource "oci_core_image" "wordpress_instance_image" {
  count          = var.numberOfNodes > 1 ? 1 : 0
  depends_on     = [null_resource.WordPress_provisioner_with_bastion]
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.WordPress.id
  display_name   = "WordPress_instance_image"
  defined_tags   = var.defined_tags
}

resource "oci_core_instance" "WordPress_from_image" {
  count               = var.numberOfNodes > 1 ? var.numberOfNodes - 1 : 0
  availability_domain = var.availability_domain == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.display_name}${count.index + 2}"
  shape               = var.shape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.flex_shape_memory
      ocpus         = var.flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id        = var.wp_subnet_id
    display_name     = "${var.label_prefix}${var.display_name}${count.index + 2}"
    assign_public_ip = false
    hostname_label   = "${var.display_name}${count.index + 2}"
  }

  dynamic "agent_config" {
    for_each = var.numberOfNodes > 1 ? [1] : []
    content {
      are_all_plugins_disabled = false
      is_management_disabled   = false
      is_monitoring_disabled   = false
      plugins_config {
        desired_state = "ENABLED"
        name          = "Bastion"
      }
    }
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_id   = oci_core_image.wordpress_instance_image[0].id
    source_type = "image"
  }

  defined_tags = var.defined_tags

  provisioner "local-exec" {
    command = "sleep 240"
  }
}

resource "oci_bastion_session" "ssh_via_bastion_service2plus" {
  depends_on = [oci_core_instance.WordPress]
  count      = var.numberOfNodes > 1 && var.use_bastion_service ? var.numberOfNodes - 1 : 0
  bastion_id = oci_bastion_bastion.bastion-service[0].id

  key_details {
    public_key_content = tls_private_key.public_private_key_pair.public_key_openssh
  }

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = oci_core_instance.WordPress_from_image[count.index].id
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = oci_core_instance.WordPress_from_image[count.index].private_ip
  }

  display_name           = "ssh_via_bastion_service_to_wordpress${count.index + 2}"
  key_type               = "PUB"
  session_ttl_in_seconds = 10800
}

resource "oci_load_balancer" "lb01" {
  count = var.numberOfNodes > 1 ? 1 : 0
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  dynamic "reserved_ips" {
    for_each = var.numberOfNodes > 1 ? [1] : []
    content {
      id = oci_core_public_ip.WordPress_public_ip_for_multi_node[0].id
    }
  }
  compartment_id = var.compartment_ocid

  subnet_ids = [
    var.lb_subnet_id,
  ]

  display_name = "wordpress_lb"
  defined_tags = var.defined_tags
}

resource "oci_load_balancer_backend_set" "lb_bes_wp" {
  count            = var.numberOfNodes > 1 ? 1 : 0
  name             = "lb_app01"
  load_balancer_id = oci_load_balancer.lb01[count.index].id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
    interval_ms         = "10000"
    return_code         = "200"
    timeout_in_millis   = "3000"
    retries             = "3"
  }
}

resource "oci_load_balancer_listener" "lb_listener_wp" {
  count                    = var.numberOfNodes > 1 ? 1 : 0
  load_balancer_id         = oci_load_balancer.lb01[count.index].id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb_bes_wp[count.index].name
  port                     = 80
  protocol                 = "HTTP"

}

resource "oci_load_balancer_backend" "lb_be_wp1" {
  count            = var.numberOfNodes > 1 ? 1 : 0
  load_balancer_id = oci_load_balancer.lb01[0].id
  backendset_name  = oci_load_balancer_backend_set.lb_bes_wp[0].name
  ip_address       = oci_core_instance.WordPress.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb_be_wp2plus" {
  count            = var.numberOfNodes > 1 ? var.numberOfNodes - 1 : 0
  load_balancer_id = oci_load_balancer.lb01[0].id
  backendset_name  = oci_load_balancer_backend_set.lb_bes_wp[0].name
  ip_address       = oci_core_instance.WordPress_from_image[count.index].private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}


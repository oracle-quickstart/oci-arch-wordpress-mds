## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_virtual_network" "wpmdsvcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = var.vcn
  dns_label      = "wpmdsvcn"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "internet_gateway"
  vcn_id         = oci_core_virtual_network.wpmdsvcn.id
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.wpmdsvcn.id
  display_name   = "nat_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.wpmdsvcn.id
  display_name   = "RouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.wpmdsvcn.id
  display_name   = "RouteTableViaNATGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_security_list" "public_security_list_ssh" {
  compartment_id = var.compartment_ocid
  display_name   = "Allow Public SSH Connections to WordPress"
  vcn_id         = oci_core_virtual_network.wpmdsvcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_security_list" "public_security_list_http" {
  compartment_id = var.compartment_ocid
  display_name   = "Allow HTTP(S) to WordPress"
  vcn_id         = oci_core_virtual_network.wpmdsvcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 443
      min = 443
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_security_list" "private_security_list" {
  compartment_id = var.compartment_ocid
  display_name   = "Private"
  vcn_id         = oci_core_virtual_network.wpmdsvcn.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = "1"
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    tcp_options {
      max = 3306
      min = 3306
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    tcp_options {
      max = 33061
      min = 33060
    }
    protocol = "6"
    source   = var.vcn_cidr
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr

    tcp_options {
      min = 2048
      max = 2050
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr

    tcp_options {
      source_port_range {
        min = 2048
        max = 2050
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr

    tcp_options {
      min = 111
      max = 111
    }
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "wp_subnet" {
  cidr_block                 = cidrsubnet(var.vcn_cidr, 8, 2)
  display_name               = "wp_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.wpmdsvcn.id
  route_table_id             = var.numberOfNodes > 1 ? oci_core_route_table.private_route_table.id : oci_core_route_table.public_route_table.id
  security_list_ids          = [oci_core_security_list.public_security_list_ssh.id, oci_core_security_list.public_security_list_http.id]
  dhcp_options_id            = oci_core_virtual_network.wpmdsvcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = var.numberOfNodes > 1 ? true : false
  dns_label                  = "wpsub"
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "lb_subnet_public" {
  count             = var.numberOfNodes > 1 ? 1 : 0
  cidr_block        = cidrsubnet(var.vcn_cidr, 8, 0)
  display_name      = "lb_public_subnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.wpmdsvcn.id
  route_table_id    = oci_core_route_table.public_route_table.id
  security_list_ids = [oci_core_security_list.public_security_list_http.id]
  dhcp_options_id   = oci_core_virtual_network.wpmdsvcn.default_dhcp_options_id
  dns_label         = "lbpub"
  defined_tags      = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "bastion_subnet_public" {
  count             = (var.numberOfNodes > 1 && var.use_bastion_service == false) ? 1 : 0
  cidr_block        = cidrsubnet(var.vcn_cidr, 8, 1)
  display_name      = "bastion_public_subnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.wpmdsvcn.id
  route_table_id    = oci_core_route_table.public_route_table.id
  security_list_ids = [oci_core_security_list.public_security_list_ssh.id]
  dhcp_options_id   = oci_core_virtual_network.wpmdsvcn.default_dhcp_options_id
  dns_label         = "bastionpub"
  defined_tags      = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "fss_subnet_private" {
  count                      = var.numberOfNodes > 1 && var.use_shared_storage ? 1 : 0
  cidr_block                 = cidrsubnet(var.vcn_cidr, 8, 4)
  display_name               = "fss_private_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.wpmdsvcn.id
  route_table_id             = oci_core_route_table.private_route_table.id
  dhcp_options_id            = oci_core_virtual_network.wpmdsvcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "fsspriv"
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_subnet" "mds_subnet_private" {
  cidr_block                 = cidrsubnet(var.vcn_cidr, 8, 3)
  display_name               = "mds_private_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.wpmdsvcn.id
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = [oci_core_security_list.private_security_list.id]
  dhcp_options_id            = oci_core_virtual_network.wpmdsvcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "mdspriv"
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}



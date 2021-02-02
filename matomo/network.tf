resource "oci_core_virtual_network" "wpmdsvcn" {
  cidr_block = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name = var.vcn
  dns_label = "wpmdsvcn"
}


resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name = "internet_gateway"
  vcn_id = oci_core_virtual_network.wpmdsvcn.id
}


resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.wpmdsvcn.id
  display_name   = "nat_gateway"
}


resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.wpmdsvcn.id
  display_name = "RouteTableForMySQLPublic"
  route_rules {
    cidr_block = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.wpmdsvcn.id
  display_name   = "RouteTableForMySQLPrivate"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_ocid
  display_name = "Allow Public SSH Connections to WordPress"
  vcn_id = oci_core_virtual_network.wpmdsvcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "public_security_list_http" {
  compartment_id = var.compartment_ocid
  display_name = "Allow HTTP(S) to WordPress"
  vcn_id = oci_core_virtual_network.wpmdsvcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "6"
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
}

resource "oci_core_security_list" "private_security_list" {
  compartment_id = var.compartment_ocid
  display_name   = "Private"
  vcn_id         = oci_core_virtual_network.wpmdsvcn.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules  {
    protocol = "1"
    source   = var.vcn_cidr
  }
  ingress_security_rules  {
    tcp_options  {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
  ingress_security_rules  {
    tcp_options  {
      max = 3306
      min = 3306
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
  ingress_security_rules  {
    tcp_options  {
      max = 33061
      min = 33060
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
}

resource "oci_core_subnet" "public" {
  cidr_block = cidrsubnet(var.vcn_cidr, 8, 0)
  display_name = "wp_public_subnet"
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.wpmdsvcn.id
  route_table_id = oci_core_route_table.public_route_table.id
  security_list_ids = [oci_core_security_list.public_security_list.id, oci_core_security_list.public_security_list_http.id]
  dhcp_options_id = oci_core_virtual_network.wpmdsvcn.default_dhcp_options_id
  dns_label = "wppub"
}

resource "oci_core_subnet" "private" {
  cidr_block                 = cidrsubnet(var.vcn_cidr, 8, 1)
  display_name               = "mds_private_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.wpmdsvcn.id
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = [oci_core_security_list.private_security_list.id]
  dhcp_options_id            = oci_core_virtual_network.wpmdsvcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "mdspriv"
}




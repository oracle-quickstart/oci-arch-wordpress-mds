data "oci_core_images" "images_for_shape" {
    compartment_id = var.compartment_ocid
    operating_system = "Oracle Linux"
    operating_system_version = "8"
    shape = "${var.node_shape}"
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}

data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ad.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")
}


data "oci_mysql_mysql_configurations" "shape" {
    compartment_id = "${var.compartment_ocid}"
    type = ["DEFAULT"]
    shape_name = var.mysql_shape
}
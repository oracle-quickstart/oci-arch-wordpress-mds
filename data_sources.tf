data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

data "oci_mysql_mysql_configurations" "shape" {
    compartment_id = "${var.compartment_ocid}"
    type = ["DEFAULT"]
    shape_name = var.mysql_shape
}
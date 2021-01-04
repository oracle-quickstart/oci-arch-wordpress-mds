module "mds-instance" {
  source         = "./modules/mds-instance"
  admin_password = var.admin_password
  admin_username = var.admin_username
  availability_domain = "${data.template_file.ad_names.*.rendered[0]}"
  configuration_id = data.oci_mysql_mysql_configurations.shape.configurations[0].id
  compartment_ocid = var.compartment_ocid
  subnet_id = "${oci_core_subnet.private.id}"
  display_name = "MySQLInstance"
}
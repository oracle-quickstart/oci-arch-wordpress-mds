module "mds-instance" {
  source               = "./modules/mds-instance"
  admin_password       = var.admin_password
  admin_username       = var.admin_username
  availability_domain  = var.availablity_domain_name
  configuration_id     = data.oci_mysql_mysql_configurations.shape.configurations[0].id
  compartment_ocid     = var.compartment_ocid
  subnet_id            = oci_core_subnet.private.id
  display_name         = "MySQLInstance"
  defined_tags         = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
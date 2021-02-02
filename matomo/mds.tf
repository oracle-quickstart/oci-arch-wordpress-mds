#module "mds-instance" {
#  source         = "./modules/mds-instance"
#  admin_password = var.admin_password
#  admin_username = var.admin_username
#  availability_domain  = var.availablity_domain_name
#  configuration_id = data.oci_mysql_mysql_configurations.shape.configurations[0].id
#  compartment_ocid = var.compartment_ocid
#  subnet_id = oci_core_subnet.private.id
#  display_name = "MySQLInstance"
#}

module "mysql-compute-instance" {
  source                = "./modules/mysql-compute-instance"
  admin_password        = var.admin_password
  admin_username        = var.admin_username
  availability_domain   = var.availablity_domain_name
  compartment_ocid      = var.compartment_ocid
  subnet_id             = oci_core_subnet.private.id
  display_name          = "MySQLInstance"
  ssh_authorized_keys   = tls_private_key.public_private_key_pair.public_key_openssh 
  ssh_private_key       = tls_private_key.public_private_key_pair.private_key_pem
  image_id              = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
}
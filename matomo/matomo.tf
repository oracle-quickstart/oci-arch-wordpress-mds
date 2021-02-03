module "matomo" {
  depends_on = [module.wordpress]
  source                = "./modules/matomo"
  availability_domain   = var.availablity_domain_name
  compartment_ocid      = var.compartment_ocid
  image_id              = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
  matomo_shape          = var.node_shape
  display_name          = "matomo"
  subnet_id             = oci_core_subnet.public.id
  ssh_authorized_keys   = tls_private_key.public_private_key_pair.public_key_openssh 
  ssh_private_key       = tls_private_key.public_private_key_pair.private_key_pem
  admin_password        = var.admin_password
  admin_username        = var.admin_username
  matomo_username       = var.matomo_username
  matomo_password       = var.matomo_password
  matomo_schema         = var.matomo_schema
  mysql_compute_ip      = module.mysql-compute-instance.private_ip
}
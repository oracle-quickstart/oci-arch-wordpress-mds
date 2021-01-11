module "wordpress" {
  source                = "./modules/wordpress"
  availability_domain   = var.availablity_domain_name
  compartment_ocid      = var.compartment_ocid
  image_id              = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
  shape                 = var.node_shape
  label_prefix          = var.label_prefix
  subnet_id             = oci_core_subnet.public.id
  ssh_authorized_keys   = tls_private_key.public_private_key_pair.public_key_openssh 
  ssh_private_key       = tls_private_key.public_private_key_pair.private_key_pem
  mds_ip                = module.mds-instance.private_ip
  admin_password        = var.admin_password
  admin_username        = var.admin_username
  wp_schema             = var.wp_schema
  wp_name               = var.wp_name
  wp_password           = var.wp_password
  wp_plugins            = var.wp_plugins
  wp_themes             = var.wp_themes
  wp_site_title         = var.wp_site_title
  wp_site_admin_user    = var.wp_site_admin_user
  wp_site_admin_pass    = var.wp_site_admin_pass
  wp_site_admin_email   = var.wp_site_admin_email
}
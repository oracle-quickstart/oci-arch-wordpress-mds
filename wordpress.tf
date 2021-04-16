## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

module "wordpress" {
  source                = "./modules/wordpress"
  availability_domain   = var.availablity_domain_name
  compartment_ocid      = var.compartment_ocid
  image_id              = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
  shape                 = var.node_shape
  flex_shape_ocpus      = var.node_flex_shape_ocpus
  flex_shape_memory     = var.node_flex_shape_memory
  label_prefix          = var.label_prefix
  display_name          = "wordpress"
  subnet_id             = oci_core_subnet.public.id
  ssh_authorized_keys   = var.ssh_public_key 
  mds_ip                = module.mds-instance.private_ip
  admin_password        = var.admin_password
  admin_username        = var.admin_username
  wp_schema             = var.wp_schema
  wp_name               = var.wp_name
  wp_password           = var.wp_password
  wp_plugins            = split(",", var.wp_plugins)
  wp_themes             = split(",", var.wp_themes)
  wp_site_title         = var.wp_site_title
  wp_site_admin_user    = var.wp_site_admin_user
  wp_site_admin_pass    = var.wp_site_admin_pass
  wp_site_admin_email   = var.wp_site_admin_email
  defined_tags          = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
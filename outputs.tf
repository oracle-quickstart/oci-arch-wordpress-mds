## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "wordpress_public_ip" {
  value = module.wordpress.public_ip[0]
}

output "bastion_ssh_metadata" {
  value = module.wordpress.bastion_ssh_metadata
}

output "wordpress_wp-admin_url" {
  value = "http://${module.wordpress.public_ip[0]}/wp-admin/"
}

output "wordpress_wp-admin_user" {
  value = var.wp_site_admin_user
}

output "wordpress_wp-admin_password" {
  value = var.wp_site_admin_pass
}

output "mds_instance_ip" {
  value = module.mds-instance.private_ip
}

output "generated_ssh_private_key" {
  value     = module.wordpress.generated_ssh_private_key
  sensitive = true
}

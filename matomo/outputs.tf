## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "wordpress_public_ip" {
  value = oci_core_public_ip.WordPress_public_ip.ip_address
}

output "matomo_public_ip" {
  value = oci_core_public_ip.MatomoInstance_public_ip.ip_address
}

output "wordpress_wp-admin_url" {
  value = "http://${oci_core_public_ip.WordPress_public_ip.ip_address}/wp-admin/"
}

output "matomo_url" {
  value = "http://${oci_core_public_ip.MatomoInstance_public_ip.ip_address}/analytics/matomo/"
}

output "wordpress_wp-admin_user" {
  value = var.wp_site_admin_user
}

output "wordpress_wp-admin_password" {
  value = var.wp_site_admin_pass
}

output "mysql_instance_ip" {
  value = data.oci_core_vnic.MySQLinstance_vnic1.private_ip_address
}

output "generated_ssh_private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
}

output "matomo_username" {
  value = var.matomo_username
}

output "matomo_password" {
  value = var.matomo_password
}

output "matomo_schema" {
  value = var.matomo_schema
}
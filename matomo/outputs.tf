output "wordpress_public_ip" {
  value = module.wordpress.public_ip
}

output "matomo_public_ip" {
  value = module.matomo.public_ip
}

output "wordpress_wp-admin_url" {
  value = "http://${module.wordpress.public_ip}/wp-admin/"
}

output "matomo_url" {
  value = "http://${module.matomo.public_ip}/analytics/matomo/"
}

output "wordpress_wp-admin_user" {
  value = var.wp_site_admin_user
}

output "wordpress_wp-admin_password" {
  value = var.wp_site_admin_pass
}

output "mysql_instance_ip" {
  value = module.mysql-compute-instance.private_ip
}

output "generated_ssh_private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
}
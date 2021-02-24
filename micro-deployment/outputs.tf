output "wordpress_public_ip" {
  value = "http://${oci_core_public_ip.WordPress_public_ip.ip_address}"
}

output "wordpress_admin_url" {
  value = "http://${oci_core_public_ip.WordPress_public_ip.ip_address}/wp-admin/"
}

output "generated_ssh_private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
}
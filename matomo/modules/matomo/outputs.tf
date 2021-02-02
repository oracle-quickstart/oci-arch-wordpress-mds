output "public_ip" {
  value = oci_core_public_ip.MatomoInstance_public_ip.ip_address
}
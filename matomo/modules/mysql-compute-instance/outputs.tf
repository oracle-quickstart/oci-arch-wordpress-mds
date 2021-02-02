output "private_ip" {
  value = data.oci_core_vnic.MySQLinstance_vnic1.private_ip_address 
}
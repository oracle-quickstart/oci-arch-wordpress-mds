
output "private_ip" {
  value = "${oci_mysql_mysql_db_system.MDSinstance.ip_address}"
}
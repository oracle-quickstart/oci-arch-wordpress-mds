## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "id" {
  value = oci_core_instance.WordPress.id
}

output "public_ip" {
  value = oci_core_public_ip.WordPress_public_ip.ip_address
}

output "wordpress_host_name" {
  value = oci_core_instance.WordPress.display_name
}

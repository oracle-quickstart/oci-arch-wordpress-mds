## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "user_ocid" {}
variable "availablity_domain_name" {}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.2"
}

variable "ssh_public_key" {
  default = ""
}

variable "vcn" {
  default = "wpmdsvcn"
}

variable "vcn_cidr" {
  description = "VCN's CIDR IP Block"
  default     = "10.0.0.0/16"
}

variable "node_shape" {
  default = "VM.Standard.A1.Flex"
}

variable "node_flex_shape_ocpus" {
  default = 1
}

variable "node_flex_shape_memory" {
  default = 10
}

variable "label_prefix" {
  default     = ""
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "8"
}

variable "admin_password" {
  description = "Password for the admin user for MySQL Database Service"
}

variable "admin_username" {
  description = "MySQL Database Service Username"
  default = "admin"
}

variable "mysql_version" {
  default     = "8.0.23"
}

variable "wp_name" {
  description = "WordPress Database User Name."
  default     = "wp"  
}

variable "wp_password" {
  description = "WordPress Database User Password." 
}

variable "wp_schema" {
  description = "WordPress MySQL Schema"
  default     = "wordpress"  
}

variable "wp_plugins" {
  description = "WordPress Plugins"
  default     = "hello-dolly,elementor"
}

variable "wp_themes" {
  description = "A list of WordPress themes to install."
  default     = "lodestar,twentysixteen"
}

variable "wp_site_url" {
  description = "WordPress Site URL"
  default = "example.com"
}

variable "wp_site_title" {
  description = "WordPress Site Title"
  default = "Yet Another WordPress Site"
}

variable "wp_site_admin_user" {
  description = "WordPress Site Admin Username"
  default = "admin"
}

variable "wp_site_admin_pass" {
  description = "WordPress Site Admin Password"
  default = ""
}

variable "wp_site_admin_email" {
  description = "WordPress Site Admin Email"
  default = "admin@example.com"  
} 

variable "matomo_username" {
  description = "Matomo Database User Name."
  default = "matomo"
}

variable "matomo_password" {
  description = "Matomo Database User Password."
}

variable "matomo_schema" {
  description = "Matomo MySQL Schema"
  default = "matomo"
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",  
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.node_shape)
}

## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "user_ocid" {}
variable "availablity_domain_name" {
  default = ""
}

variable "ssh_public_key" {
  default = ""
}

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.4.1"
}

variable "vcn" {
  default = "wpmdsvcn"
}

variable "vcn_cidr" {
  description = "VCN's CIDR IP Block"
  default     = "10.0.0.0/16"
}

variable "numberOfNodes" {
  description = "Create one or more nodes with WordPress"
  default     = 2
}

variable "use_shared_storage" {
  description = "Decide if you want to use shared NFS on OCI FSS"
  default     = true
}

variable "node_shape" {
  default = "VM.Standard.E3.Flex"
}

variable "node_flex_shape_ocpus" {
  default = 1
}

variable "node_flex_shape_memory" {
  default = 10
}

variable "use_bastion_service" {
  default = false
}

variable "bastion_shape" {
  default = "VM.Standard.E3.Flex"
}

variable "bastion_flex_shape_ocpus" {
  default = 1
}

variable "bastion_flex_shape_memory" {
  default = 1
}

variable "label_prefix" {
  default = ""
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
  default     = "admin"
}

variable "mysql_shape" {
  default = "MySQL.VM.Standard.E3.1.8GB"
}

variable "mysql_is_highly_available" {
  default = false
}

variable "wp_name" {
  description = "WordPress Database User Name."
  default     = "wp"
}

variable "wp_password" {
  description = "WordPress Database User Password."
  #  default     = "MyWPpassw0rd!"  
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
  default     = "example.com"
}

variable "wp_site_title" {
  description = "WordPress Site Title"
  default     = "Yet Another WordPress Site"
}

variable "wp_site_admin_user" {
  description = "WordPress Site Admin Username"
  default     = "admin"
}

variable "wp_site_admin_pass" {
  description = "WordPress Site Admin Password"
  default     = ""
}

variable "wp_site_admin_email" {
  description = "WordPress Site Admin Email"
  default     = "admin@example.com"
}


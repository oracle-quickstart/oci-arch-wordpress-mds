# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
#variable "fingerprint" {}
#variable "private_key_path" {}
#variable "user_ocid" {}
variable "availability_domain_name" {
  default = null
}


## Networking

variable "vcn" {
  default = "wpmdsvcn"
}

variable "vcn_cidr" {
  description = "VCN's CIDR IP Block"
  default     = "10.0.0.0/16"
}

## Instance

variable "instance_shape" {
  default = "VM.Standard.E3.Flex"
}
variable "instance_ocpus" {
  default = 1
}
variable "instance_shape_config_memory_in_gbs" {
  default = 16
}

variable "label_prefix" {
  default     = ""
}

variable "instance_os" {
  description = "Operating system."
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version."
  default     = "7.9"
}

variable "generate_public_ssh_key" {
  default = true
}
variable "public_ssh_key" {
  default = ""
}

# MySQL

variable "wp_db_user" {
  description = "The username that WordPress uses to connect to the MySQL database."
  default     = "wp"  
}

variable "wp_schema" {
  description = "WordPress MySQL Schema"
  default     = "wordpress"  
}

# WordPress


variable "wp_admin_user" {
  description = "The username for the WordPress administrator."
  default     = "admin"  
}

variable "wp_admin_password" {
  description = "Password for the WordPress administrator."
}
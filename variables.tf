variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "user_ocid" {}
variable "availablity_domain_name" {}

variable "vcn" {
  default = "wpmdsvcn"
}

variable "vcn_cidr" {
  description = "VCN's CIDR IP Block"
  default     = "10.0.0.0/16"
}

variable "node_shape" {
  default     = "VM.Standard.E2.1"
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
  default     = "7.8"
}

variable "admin_password" {
  description = "Password for the admin user for MySQL Database Service"
}

variable "admin_username" {
  description = "MySQL Database Service Username"
  default = "admin"
}

variable "mysql_shape" {
    default = "VM.Standard.E2.1"
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
  type        = list(string)
  description = "WordPress Plugins"
  default     = ["hello-dolly"]  
}

variable "wp_themes" {
  type        = list(string)
  description = "A list of WordPress themes to install."
  default     = ["lodestar","twentysixteen"]
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

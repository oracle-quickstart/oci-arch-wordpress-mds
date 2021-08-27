## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "mysql_version" {
  description = "The version of the Mysql Shell."
  default     = "8.0.21"
}

variable "tenancy_ocid" {
}

variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "availability_domain" {
  description = "The Availability Domain of the instance. "
  default     = ""
}

variable "display_name" {
  description = "The name of the instance. "
  default     = ""
}

variable "numberOfNodes" {
  description = "Create one or more nodes with WordPress"
  default     = 1
}

variable "vcn_id" {
  description = "The OCID of the VCN"
  default     = ""
}

variable "wp_subnet_id" {
  description = "The OCID of the WordPress subnet to create the VNIC for public/private access. "
  default     = ""
}

variable "lb_subnet_id" {
  description = "The OCID of the Load Balancer subnet to create the VNIC for public access. "
  default     = ""
}

variable "bastion_subnet_id" {
  description = "The OCID of the Bastion subnet to create the VNIC for public access. "
  default     = ""
}

variable "fss_subnet_id" {
  description = "The OCID of the File Storage Service subnet to create the VNIC for private access. "
  default     = ""
}

variable "shape" {
  default = "VM.Standard.E3.Flex"
}

variable "flex_shape_ocpus" {
  default = 1
}

variable "flex_shape_memory" {
  default = 10
}

variable "use_bastion_service" {
  default = false
}

variable "bastion_service_region" {
  description = "Bastion Service Region"
  default     = ""
}

variable "bastion_image_id" {
  default = ""
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

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}


variable "use_shared_storage" {
  description = "Decide if you want to use shared NFS on OCI FSS"
  default     = true
}

variable "wp_working_dir" {
  description = "Decide where to store WordPress data"
  default     = "/var"
}

variable "wp_shared_working_dir" {
  description = "Decide where to store WordPress data"
  default     = "/sharedwp"
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default     = ""
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "image_id" {
  description = "The OCID of an image for an instance to use. "
  default     = ""
}

variable "vm_user" {
  description = "The SSH user to connect to the master host."
  default     = "opc"
}

variable "wp_name" {
  description = "WordPress Database User Name."
}

variable "wp_password" {
  description = "WordPress Database User Password."
}

variable "wp_schema" {
  description = "WordPress MySQL Schema"
}

variable "admin_username" {
  description = "Username od the MDS admin account"
}

variable "admin_password" {
  description = "Password for the admin user for MDS"
}

variable "mds_ip" {
  description = "Private IP of the MDS Instance"
}

variable "wp_plugins" {
  type        = list(string)
  description = "A list of WordPress plugins to install."
  default     = ["hello-dolly"]
}

variable "wp_themes" {
  type        = list(string)
  description = "A list of WordPress themes to install."
  default     = ["lodestar", "twentysixteen"]
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

variable "defined_tags" {
  description = "Defined tags for WordPress host."
  default     = ""
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
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.shape)
  is_flexible_lb_shape   = var.lb_shape == "flexible" ? true : false
}

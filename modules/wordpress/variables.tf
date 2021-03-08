variable "mysql_version" {
  description = "The version of the Mysql Shell."
  default     = "8.0.21"
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

variable "subnet_id" {
  description = "The OCID of the Shell subnet to create the VNIC for public access. "
  default     = ""
}

variable "shape" {
  description = "Instance shape to use for master instance. "
  default     = "VM.Standard2.1"
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

variable "defined_tags" {
  description = "Defined tags for WordPress host."
  default     = ""
}
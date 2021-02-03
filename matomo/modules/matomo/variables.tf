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
  description = "The OCID of the master subnet to create the VNIC in. "
  default     = ""
}

variable "matomo_shape" {
  description = "Instance shape to use."
  default     = "VM.Standard.E2.1"
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

variable "matomo_username" {
  description = "Matomo Database User Name."
}

variable "matomo_password" {
  description = "Matomo Database User Password."
}

variable "matomo_schema" {
  description = "Matomo MySQL Schema"
}

variable "admin_username" {
    description = "Username of the MySQL admin account"
}

variable "admin_password" {
    description = "Password for the admin user for MySQL"
}

variable "mysql_compute_ip" {
    description = "Private IP of the MySQL Compute Instance"
}

variable "vm_user" {
  description = "The SSH user to connect to the master host."
  default     = "opc"
}

variable "mysql_version" {
  description = "The version of the Mysql Shell."
  default     = "8.0.21"
}

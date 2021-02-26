# oci-wordpress-micro

This repository provides a minimal WordPress deployment on Oracle Cloud Infrastructure. This deployment utilizes a single compute instance in order to deploy both WordPress as well as a MySQL database.
Both WordPress as well as MySQL are deployed using Docker containers. There are two ways to deploy this solution. The first method utilizes Oracle Resource Manager, a managed Terraform service in Oracle Cloud Infrastructure. Secondly, this solution can be deployed using terraform.

## Deploy Using Oracle Resource Manager

To deploy this solution using Oracle Resource Manager, click on the deployment button below to start the deployment in your oracle cloud infrastructure tenancy.

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-arch-wordpress-mds/releases/latest/download/oci-wordpress-micro-stack-latest.zip)

Alternatively, you can download the stack for this solution from the **Releases** a section of this repository. Navigate to Oracle resource manager in the Oracle Cloud Infrastructure console. Here import the zip file as a new resource manager stack.You can now perform terraform actions like plan or apply.

The stack exposes several variables that can be configured. By default the stack only prompts the user for the administrative password for WordPress. Users can choose to use the advanced options to provide further configuration of the stack.

## Deploy Using the Terraform CLI

### Clone the Module

Now, you'll want a local copy of this repo. You can make that with the commands:

```
    git clone https://github.com/oracle-quickstart/oci-arch-wordpress-mds.git
    cd oci-arch-wordpress-mds/micro-deployment
    ls
```

### Prerequisites
First off, you'll need to do some pre-deploy setup.  That's all detailed [here](https://github.com/cloud-partners/oci-prerequisites).

Create a `terraform.tfvars` file, and specify the following variables:

```
# Authentication
tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<user_ocid>"
fingerprint          = "<finger_print>"
private_key_path     = "<pem_private_key_path>"

# Region
region = "<oci_region>"

# Availablity Domain 
availablity_domain_name = "<availablity_domain_name>"

```

You also need to uncomment the following lines in the `provider.tf`.
```
   user_ocid = var.user_ocid
   fingerprint = var.fingerprint
   private_key_path = var.private_key_path
```
### Create the Resources
Run the following commands:

    terraform init
    terraform plan
    terraform apply


### Testing your Deployment
After the deployment is finished, you can access WP-Admin by picking wordpress_wp-admin_url output and pasting into web browser window. You can also verify initial content of your blog by using wordpress_public_ip:

````
wordpress_wp-admin_url = http://193.122.198.19/wp-admin/
wordpress_public_ip = 193.122.198.19
`````

### Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy the resources:

    terraform destroy

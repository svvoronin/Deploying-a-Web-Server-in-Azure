# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction

For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started

1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies

1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions (for Azure CLI)

#### Set environment variables

1. `az login`
2. Get credentials' details:
   `az ad sp create-for-rbac --role Contributor --scopes /subscriptions/"Subscription id" --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"`
3. Set env variables with Service Principal with Azure CLI (for Windows)

```
set ARM_SUBSCRIPTION_ID=[Subscription id]
set ARM_CLIENT_ID=[Client id]
set ARM_CLIENT_SECRET=[Client Secret]
set ARM_TENANT_ID=[Tenant id]
```

4. Other required variables are defined in vars.tf with default values:

- source_image_rg: resource group name where packer image is deployed
- source_image_name: packer image name
- username: account username
- password: account password
- location: Azure region
- vm_count: Number of VMs to deploy
- prefix: resouce prefix
- tags: resource tag

#### Create a custom policy

1. Creat definition: `az policy definition create --name "policy name" --rules "<path to .json file>"`
2. Create assignment: `az policy assignment create --name "policy name" --scope /subscriptions/%ARM_SUBSCRIPTION_ID% --policy /subscriptions/%ARM_SUBSCRIPTION_ID%/providers/Microsoft.Authorization/policyDefinitions/"policy name"`
3. Verify created assignment: `az policy assignment list`

#### Create web server image with packer

1. Build image: `packer build server.json`
2. Verify the image created: `az image list`

#### Create infrastructure with Terraform

1. Init terraform: `terraform init`
2. Evaluate terraform configuration to determine the desired state of all the resources it declares: `terraform plan -out solution.plan`
3. Create Infrastructure with terraform: `terraform apply`

### Output

The following resources will be built:

1. Resource group
2. Virtual network (with subnet on that virtual network)
3. Network security group
4. Network Intereface card(s)
5. Public IP address
6. Load Balancer
7. Backend address pool for load balancer
8. Address pool association for the network interface and the load balancer
9. Virtual machine(s)
10. Virtual machine availability set
11. Managed disk(s) for virtual machine(s) with the disk attachement(s)

The exact number of deployed resources is based on vm_count value in vars.tf

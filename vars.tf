variable "source_image_rg" {
  description = "The resource group of the vm source image"
  //default     = "deploy-server-ng"
  default = "az-webserver-si-rg"
}

variable "source_image_name" {
  description = "The vm source image name"
  //default     = "PackerServerImage"
  default = "az-webserver-si"
}

variable "username" {
  description = "The username for SSH connection into vm"
  default     = "azureuser"
}

variable "password" {
  description = "The password for SSH connection into vm"
  default     = "@Pass1234pasS@"
}

variable "location" {
  description = "The Azure Region to create resources"
  default     = "Switzerland North"
}

variable "vm_count" {
  description = "VM number to deploy"
  type        = number
  default     = 3
}

variable "prefix" {
  description = "The prefix for resources in the template"
  default     = "az-webserver"
}

variable "tags" {
  description = "A tag to use for the deployed resources"
  type        = map(string)

  default = {
    Name = "az-webserver"
  }

}

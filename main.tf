provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-RG"
  location = var.location

  tags = var.tags

}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-VN"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.tags

}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/16"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-NSG"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SubnetAccess-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "SubnetAccess-Outbound"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "InternetAccess"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = var.tags
}

resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "${var.prefix}-NIC-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal-${count.index}"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-PIP"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-LB"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "internal"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "main" {
  name            = "${var.prefix}-LB-BP"
  loadbalancer_id = azurerm_lb.main.id

}

resource "azurerm_lb_backend_address_pool_address" "main" {
  name                    = "${var.prefix}-LB-BP-ADDRESS"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = "10.0.0.10"
}

resource "azurerm_availability_set" "main" {
  name                        = "${var.prefix}-AS"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  platform_fault_domain_count = 2

  tags = var.tags

}

data "azurerm_image" "main" {
  name                = var.source_image_name
  resource_group_name = var.source_image_rg
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm_count
  name                            = "${var.prefix}-VM-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1s"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  availability_set_id = azurerm_availability_set.main.id
  source_image_id     = data.azurerm_image.main.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = var.tags
}


resource "azurerm_managed_disk" "main" {
  count                = var.vm_count
  name                 = "${var.prefix}-MD-${count.index}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  tags = var.tags

}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.main[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}

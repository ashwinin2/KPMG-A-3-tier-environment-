# first we will create an Terraform Directory #
#later we can create this below Main.tf file for declaring our providers
# In my case i am making use of Azure since we have worked on Azure cloud#

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "version of the Terraform"
    }
  }
  Environment: staging
}

# In order to configure our Azure provider we can see use below code
provider "azurerm" {
  features {}
}

# Later we need the Vnet and subnet for our infrastructure
resource "azurerm_resource_group" "Ashwini" {
  name     = "Ash-Resources"
  location = "we can give the location here for example: East US"
}
# Network Security group is also very important wen we create the Virtual network  

resource "azurerm_network_security_group" "Ashwini" {
  name                = "Ash-security-group"
  location            = azurerm_resource_group.Ashwini.location # here it is going to reference the location of our resource group created.
  resource_group_name = azurerm_resource_group.Ashwini.name # here it is going to reference the name  of our resource group created.
}

resource "azurerm_virtual_network" "Ashwini" {
  name                = "Ashu-network"
  location            = azurerm_resource_group.Ashwini.location
  resource_group_name = azurerm_resource_group.Ashwini.name
  address_space       = ["10.0.0.0/16"] # Here address space is nothing but the Range of Ip Address ryt , so azure will assign the next availble Ip addr from this Addrs space to a resource in our Virtual network.
  The above ["10.0.0.0/16"] is just an example and it falls under Class A Networks.
  

  # So again here the subnets are nothing but a logical segment of a Virtual network where it is allocated a portion of a virtual networks addr space.
  subnet {
    name           = "subnet1"
    address_prefix = "we can give the Subnet Range 01"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "the second subnet Range 02"
    security_group = azurerm_network_security_group.Ashwini.id
 
  }
}
# in same way i think we can create an subnets for both application and database.
# Once like all this Resource group, Vnet, subnets etc is created we can now create our Virtual machines for our web servers .

# same way we can create 2 more Virtual machines for the environments .


resource "azurerm_linux_virtual_machine" "Ashwini" {
  name                = "Vm1"
  resource_group_name = azurerm_resource_group.Ashwini.name
  location            = azurerm_resource_group.Ashwini.location
  size                = "Standard_F2"
  admin_username      = "adminuser"


  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
# we are now going to create an Azure load balancer if there is any traffic to this web server so that this can balance the traffic in this.

resource "azurerm_lb" "Ashwini" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.Ashwini.location
  resource_group_name = azurerm_resource_group.Ashwini.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.Ashwini.id
  }
}

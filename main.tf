resource "aws_instance" "aws_vm" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform-AWS-VM"
  }
}
resource "azurerm_resource_group" "rg" {
  name     = "terraform-rg"
  location = "Southeast Asia"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "terraform-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "terraform-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_public_ip" "publicip" {
  name                = "terraform-publicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "terraform-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_linux_virtual_machine" "azure_vm" {
  name                = "terraform-azure-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2pts_v2"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_password                  = "Password@12345"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server-arm64"
    version   = "latest"
  }
}
 resource "google_compute_instance" "gcp_vm" {
   name         = "terraform-gcp-vm"
   machine_type = "e2-medium"
   zone         = "asia-south1-a"

   boot_disk {
     initialize_params {
       image = "debian-cloud/debian-11"
     }
   }

   network_interface {
     network = "default"
 
     access_config {
    }
   }
 }

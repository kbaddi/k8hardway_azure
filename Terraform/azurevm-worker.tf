#Build Worker nodes

#Fetch the Cloudinit (userdate) file

data "template_file" "worker" {
  template = file("${path.module}/Templates/cloudnint-worker.tpl")
}

resource "azurerm_virtual_machine" "worker" {
  count                 = var.worker_node_count
  name                  = "worker-${count.index}"
  location              = azurerm_resource_group.k8hway.location
  resource_group_name   = azurerm_resource_group.k8hway.name
  network_interface_ids = [element(azurerm_network_interface.worker.*.id, count.index)]
  vm_size               = var.worker_vm_size

  tags = {
    Name  = "${count.index}-worker" 
    pod-cidr = "10.240.${count.index}.0/24"

  }
  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-worker-${count.index}-worker-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "worker-${count.index}"
    admin_username = var.admin_username
    custom_data    = data.template_file.worker.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = data.template_file.key_data.rendered
      path     = var.destination_ssh_key_path
    }
  }
}

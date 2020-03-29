// resource "azurerm_public_ip" "ext_lb" {
//   count               = var.worker_node_count
//   name                = "ext-lb"
//   resource_group_name = azurerm_resource_group.k8hway.name
//   location            = azurerm_resource_group.k8hway.location
//   allocation_method   = "Static"
//   sku                 = "Standard"
//   tags                = var.tags
// }



// resource "azurerm_lb" "k8hway" {
//   name                = "ext_lb"
//   location            = "East US"
//   resource_group_name = azurerm_resource_group.k8hway.name

//   frontend_ip_configuration {
//     name                 = "PublicIPAddress"
//     public_ip_address_id = azurerm_public_ip.ext_lb.id
//     subnet_id = azurerm_subnet.public.id
//   }
// }       

// resource "azurerm_lb_probe" "k8hardway" {
//   resource_group_name = azurerm_resource_group.k8hardway.name
//   loadbalancer_id     = azurerm_lb.k8hardway.id
//   name                = "k8hardway_probe"
//   port                = 6443
 
// }



// resource "azurerm_lb_backend_address_pool" "k8hardway" {
//   resource_group_name = azurerm_resource_group.k8hardway.name
//   loadbalancer_id     = azurerm_lb.k8hardway.id
//   name                = "BackEndAddressPool"
// }





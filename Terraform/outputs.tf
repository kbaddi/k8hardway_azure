


output "master_node_private_ips" {
    value = [azurerm_network_interface.master.*.private_ip_address]
}

output "master_node_public_ips" {
    value = [azurerm_public_ip.master.*.ip_address]
}

output "woker_node_public_ips" {
    value = [azurerm_public_ip.worker.*.ip_address]
}

output "worker_node_private_ips" {
    value = [azurerm_network_interface.worker.*.private_ip_address]
}
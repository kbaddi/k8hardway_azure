variable "prefix" {
}

// variable "virtual_machine_name" {
// }

variable "location" {
}

variable "admin_username" {
}

// variable "susbcription_id" {
// }
// variable "bastion_vm_size" {

//   description = "Size of the bastion Node"
//   default = "Standard_B1ls"
// }

// variable "bastion_inbound_ports" {
//   type = list
// }

variable "master_node_count" {
}

variable "worker_node_count" {
}

variable "master_vm_size" {
  description = "Size of the Master Node"
}

variable "worker_vm_size" {
  description = "Size of the Worker Nodes"
}

variable "destination_ssh_key_path" {
  description = "Path where ssh keys are copied in the vm. Only /home/<username>/.ssh/authorize_keys is accepted."
}

variable "master_inbound_ports" {
  type = list(string)
}

variable "worker_inbound_ports" {
  type = list(string)
}

variable "tags" {
  type = map(string)

  default = {
    name = "k8s"
  }

  description = "Any tags which should be assigned to the resources in this example"
}


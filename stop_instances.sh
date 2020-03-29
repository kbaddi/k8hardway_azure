#!/bin/bash

# Script to Stop all the instances.

export resource_group="k8hardway-RG"

#Stop worker nodes. 

for instance in worker-0 worker-1; 
do
  az vm stop -g $resource_group -n $instance
done



# Stop Master Nodes

for instance in master-0 master-1 master-2;
do
  az vm stop -g $resource_group -n $instance
done
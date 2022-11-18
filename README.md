# Terraform Azure load balancer template

This terraform template creates a new resource group with 3 VMs in seperate availability zones with associated load balancer.
The VMS have access to private SQL server.

The VMs have access to internet via load balancer NAT.
VMs have associated extensions to install an Apache server.

# How to run it

Authenticate to Azure cli
```
az login
```
Initialize the terraform 
```
terraform init
```
Create a plan for the deployment and verify if everything is correct
```
terraform plan
```
Apply the deployment plant
```
terraform apply
```
It may take some time before the resources are created
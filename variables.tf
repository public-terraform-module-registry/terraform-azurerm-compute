variable "resource_group_name" {
  description = "(Required)The name of the resource group in which the resources will be created"
}

variable "location" {
  description = "(Required)The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

### avaulability options
variable "zones" {
  description = "(Optional)a single item of the Availability Zone which the Virtual Machine should be allocated."
  default     = ""
}

## availability_set settings
variable "availability_set_name" {
  description = "(Optional)Specifies the name of the availability set. Changing this forces a new resource to be created."
  default     = ""
}

variable "platform_update_domain_count" {
  description = "(Optional) Specifies the number of update domains that are used. Defaults to 5."
  default     = "5"
}

variable "platform_fault_domain_count" {
  description = "(Optional) Specifies the number of fault domains that are used. Defaults to 3."
  default     = "3"
}

variable "managed" {
  description = "(Optional) Specifies whether the availability set is managed or not. Possible values are true (to specify aligned) or false (to specify classic). Default is true."
  default     = "true"
}

##
###

## basit settings
variable "vm_hostname" {
  description = "local name of the VM"
}

variable "nb_instances" {
  description = "Specify the number of vm instances"
  default     = "1"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_DS1_V2"
}

variable "tags" {
  type        = "map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

##

## network settings
variable "vnet_subnet_id" {
  description = "(Required)The subnet id of the virtual network where the virtual machines will reside."
}

variable "public_ip_dns" {
  description = "Optional globally unique per datacenter region domain name label to apply to each public ip address. e.g. thisvar.varlocation.cloudapp.azure.com where you specify only thisvar here. This is an array of names which will pair up sequentially to the number of public ips defined in var.nb_public_ip. One name or empty string is required for every public ip. If no public ip is desired, then set this to an array with a single empty string."
  default     = [""]
}

variable "public_ip_address_allocation" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  default     = "dynamic"
}

variable "nb_public_ip" {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  default     = "0"
}

variable "enable_accelerated_networking" {
  type        = "string"
  description = "(Optional) Enable accelerated networking on Network interface"
  default     = "false"
}

##

## OS settings
variable "admin_username" {
  description = "The admin username of the VM that will be deployed"
  default     = "sysadmin"
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure"
  default     = ""
}

variable "disable_password_authentication" {
  description = "Set true to use public key authentication"
  default     = "false"
}

variable "ssh_key" {
  description = "Path to the public key to be used for ssh access to the VM.  Only used with non-Windows vms and can be left as-is even if using Windows vms. If specifying a path to a certification on a Windows machine to provision a linux vm use the / in the path versus backslash. e.g. c:/home/id_rsa.pub"
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_ssh_key" {
  description = "Path to the private key to be used for ssh access to the VM."
  default     = "~/.ssh/id_rsa"
}

variable "remote_port" {
  description = "Remote tcp port to be used for access to the vms created via the nsg applied to the nics."
  default     = ""
}

variable "custom_data" {
  description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  default     = ""
}

##

## OS disk settings
variable "storage_account_type" {
  description = "(Optional)Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  default     = "Premium_LRS"
}

variable "os_disk_caching" {
  description = "(Optional) Specifies the caching requirements for the OS Disk. Possible values include None, ReadOnly and ReadWrite.Default value is set to ReadWrite."
  default     = "ReadWrite"
}

variable "delete_os_disk_on_termination" {
  description = "Delete os disk when machine is terminated"
  default     = "false"
}

##

## image settings
variable "vm_os_simple" {
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os.  Do not provide this value if a custom value is used for vm_os_publisher, vm_os_offer, and vm_os_sku."
  default     = ""
}

variable "vm_os_id" {
  description = "The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is_windows_image = true for windows custom images."
  default     = ""
}

variable "is_windows_image" {
  description = "Boolean flag to notify when the custom image is windows based."
  default     = "false"
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = ""
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = ""
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. This is ignored when vm_os_id or vm_os_simple are provided."
  default     = "latest"
}

##

### boot diagnostics settings
variable "boot_diagnostics" {
  description = "(Optional) Enable or Disable boot diagnostics"
  default     = "false"
}

variable "boot_diagnostics_sa_name" {
  description = "(Optional) Name of storage account boot diagnostics"
}

variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics"
  default     = "Standard_LRS"
}

## A network_rules block 
variable "default_action" {
  description = "(Required) Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow"
  default     = "Deny"
}

variable "virtual_network_subnet_ids" {
  description = "(Required) A list of resource ids for subnets."
  type        = "list"
}

###


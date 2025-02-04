provider "azurerm" {
  version = ">= 1.1.0"
}

provider "random" {
  version = "~> 2.1"
}

module "os" {
  source       = "./os"
  vm_os_simple = "${var.vm_os_simple}"
}

resource "azurerm_storage_account" "vm-sa" {
  count                    = "${var.boot_diagnostics == "true" ? 1 : 0}"
  name                     = "${var.boot_diagnostics_sa_name}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  account_tier             = "${element(split("_", var.boot_diagnostics_sa_type),0)}"
  account_replication_type = "${element(split("_", var.boot_diagnostics_sa_type),1)}"

  network_rules {
    default_action             = "${var.default_action}"
    virtual_network_subnet_ids = ["${var.virtual_network_subnet_ids}"]
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "vm-linux-no-az" {
  count                         = "${!contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "Windows") && var.is_windows_image != "true"  && var.zones == "" && var.availability_set_name == "" ? var.nb_instances : 0}"
  name                          = "${var.vm_hostname}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  vm_size                       = "${var.vm_size}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }

  storage_os_disk {
    name              = "${var.vm_hostname}${format("os%03d",count.index+1)}"
    create_option     = "FromImage"
    caching           = "${var.os_disk_caching}"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    custom_data    = "${var.custom_data}"
  }

  os_profile_linux_config {
    disable_password_authentication = "${var.disable_password_authentication}"

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_key}")}"
    }
  }

  tags = "${var.tags}"

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
  }

  depends_on = ["azurerm_storage_account.vm-sa"]
}

resource "azurerm_virtual_machine" "vm-linux-with-az" {
  count                         = "${!contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "Windows") && var.is_windows_image != "true" && var.zones != "" && var.availability_set_name == "" ? var.nb_instances : 0}"
  name                          = "${var.vm_hostname}"
  location                      = "${var.location}"
  zones                         = ["${var.zones}"]
  resource_group_name           = "${var.resource_group_name}"
  vm_size                       = "${var.vm_size}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }

  storage_os_disk {
    name              = "${var.vm_hostname}${format("os%03d",count.index+1)}"
    create_option     = "FromImage"
    caching           = "${var.os_disk_caching}"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    custom_data    = "${var.custom_data}"
  }

  os_profile_linux_config {
    disable_password_authentication = "${var.disable_password_authentication}"

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_key}")}"
    }
  }

  tags = "${var.tags}"

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
  }

  depends_on = ["azurerm_storage_account.vm-sa"]
}

resource "azurerm_virtual_machine" "vm-linux-with-availability-set" {
  count                         = "${!contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "Windows") && var.is_windows_image != "true"  && var.zones == "" && var.availability_set_name != "" ? var.nb_instances : 0}"
  name                          = "${var.vm_hostname}"
  location                      = "${var.location}"
  availability_set_id           = "${azurerm_availability_set.vm-av.id}"
  resource_group_name           = "${var.resource_group_name}"
  vm_size                       = "${var.vm_size}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }

  storage_os_disk {
    name              = "${var.vm_hostname}${format("os%03d",count.index+1)}"
    create_option     = "FromImage"
    caching           = "${var.os_disk_caching}"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    custom_data    = "${var.custom_data}"
  }

  os_profile_linux_config {
    disable_password_authentication = "${var.disable_password_authentication}"

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_key}")}"
    }
  }

  tags = "${var.tags}"

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
  }

  depends_on = ["azurerm_storage_account.vm-sa", "azurerm_availability_set.vm-av"]
}

resource "azurerm_virtual_machine" "vm-windows-no-az" {
  count                         = "${((var.is_windows_image == "true" || contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "Windows"))) &&  var.zones == "" && var.availability_set_name == ""  ? var.nb_instances : 0}"
  name                          = "${var.vm_hostname}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  vm_size                       = "${var.vm_size}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }

  storage_os_disk {
    name              = "${var.vm_hostname}${format("os%03d",count.index+1)}"
    create_option     = "FromImage"
    caching           = "${var.os_disk_caching}"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  tags = "${var.tags}"

  os_profile_windows_config {
    provision_vm_agent = true
  }

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
  }

  depends_on = ["azurerm_storage_account.vm-sa"]
}

resource "azurerm_virtual_machine" "vm-windows-with-az" {
  count                         = "${((var.is_windows_image == "true" || contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "Windows")) ) &&  var.zones != "" && var.availability_set_name == "" ? var.nb_instances : 0}"
  name                          = "${var.vm_hostname}"
  location                      = "${var.location}"
  zones                         = ["${var.zones}"]
  resource_group_name           = "${var.resource_group_name}"
  vm_size                       = "${var.vm_size}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }

  storage_os_disk {
    name              = "${var.vm_hostname}${format("os%03d",count.index+1)}"
    create_option     = "FromImage"
    caching           = "${var.os_disk_caching}"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  tags = "${var.tags}"

  os_profile_windows_config {
    provision_vm_agent = true
  }

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
  }

  depends_on = ["azurerm_storage_account.vm-sa"]
}

resource "azurerm_virtual_machine" "vm-windows-with-availability-set" {
  count                         = "${((var.is_windows_image == "true" || contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "Windows")) ) &&  var.zones == "" && var.availability_set_name != "" ? var.nb_instances : 0}"
  name                          = "${var.vm_hostname}"
  location                      = "${var.location}"
  availability_set_id           = "${azurerm_availability_set.vm-av.id}"
  resource_group_name           = "${var.resource_group_name}"
  vm_size                       = "${var.vm_size}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }

  storage_os_disk {
    name              = "${var.vm_hostname}${format("os%03d",count.index+1)}"
    create_option     = "FromImage"
    caching           = "${var.os_disk_caching}"
    managed_disk_type = "${var.storage_account_type}"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  tags = "${var.tags}"

  os_profile_windows_config {
    provision_vm_agent = true
  }

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
  }

  depends_on = ["azurerm_storage_account.vm-sa", "azurerm_availability_set.vm-av"]
}

resource "azurerm_public_ip" "vm" {
  count                        = "${var.nb_public_ip}"
  name                         = "${var.vm_hostname}${format("publicIP%03d",count.index+1)}"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "${var.public_ip_address_allocation}"
  domain_name_label            = "${element(var.public_ip_dns, count.index)}"
  tags                         = "${var.tags}"
}

resource "azurerm_network_interface" "vm" {
  count                         = "${var.nb_instances}"
  name                          = "${var.vm_hostname}${format("nic%03d",count.index+1)}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  enable_accelerated_networking = "${var.enable_accelerated_networking}"

  ip_configuration {
    name                          = "${format("ipconfig%03d",count.index+1)}"
    subnet_id                     = "${var.vnet_subnet_id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, list("")), count.index) : ""}"
  }

  tags = "${var.tags}"
}

resource "azurerm_availability_set" "vm-av" {
  location                     = "${var.location}"
  name                         = "${var.availability_set_name}"
  platform_update_domain_count = "${var.platform_update_domain_count}"
  platform_fault_domain_count  = "${var.platform_fault_domain_count}"
  resource_group_name          = "${var.resource_group_name}"
  managed                      = "${var.managed}"
}

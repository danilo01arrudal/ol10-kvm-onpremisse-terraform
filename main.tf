module "vm" {
  source = "./modules/vm"

  name          = var.vm_config.name
  memory        = var.vm_config.memory
  vcpus         = var.vm_config.vcpus
  disk_size_gb  = var.vm_config.disk_size_gb
  disk_size_mb  = var.vm_config.disk_size_mb
  swap_size_mb  = var.vm_config.swap_size_mb
  ip            = var.vm_config.ip
  gateway       = var.vm_config.gateway
  netmask       = var.vm_config.netmask
  dns           = var.vm_config.dns
  hostname      = var.vm_config.hostname
  iso_path      = var.vm_config.iso_path
  disk_path     = var.vm_config.disk_path
  network       = var.vm_config.network
  timezone      = var.vm_config.timezone
  root_password_hash = var.vm_config.root_password_hash
  user_name     = var.vm_config.user_name
  user_password_hash = var.vm_config.user_password_hash
}

# Expressões locais para simplificar e reutilizar valores
locals {
  # Exemplo: concatenar nome do ambiente com nome da VM
  full_vm_name = "${var.environment}-${var.vm_config.name}"
}

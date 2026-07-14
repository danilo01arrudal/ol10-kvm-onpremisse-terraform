output "vm_name" {
  description = "Nome da VM"
  value       = var.name
}

output "vm_ip" {
  description = "IP da VM"
  value       = var.ip
}

output "kickstart_file" {
  description = "Caminho do arquivo kickstart gerado"
  value       = local_file.ks.filename
}

output "ssh_command" {
  description = "Comando SSH para a VM"
  value       = "ssh ${var.user_name}@${var.ip}"
}

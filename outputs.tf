output "vm_name" {
  description = "Nome da VM criada"
  value       = module.vm.vm_name
}

output "vm_ip" {
  description = "IP configurado para a VM"
  value       = module.vm.vm_ip
}

output "kickstart_file" {
  description = "Caminho do arquivo kickstart gerado"
  value       = module.vm.kickstart_file
}

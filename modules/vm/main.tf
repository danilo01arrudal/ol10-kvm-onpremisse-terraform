# Geração do arquivo kickstart a partir do template
resource "local_file" "ks" {
  content = templatefile("${path.module}/templates/ks.cfg.tpl", {
    ip                  = var.ip
    gateway             = var.gateway
    netmask             = var.netmask
    dns                 = var.dns
    hostname            = var.hostname
    disk_size_mb        = var.disk_size_mb
    root_size_mb        = local.root_size_mb
    swap_size_mb        = var.swap_size_mb
    timezone            = var.timezone
    root_password_hash  = var.root_password_hash
    user_name           = var.user_name
    user_password_hash  = var.user_password_hash
  })
  filename = "${path.module}/../../data/kickstart/${local.ks_filename}"
}

# Recurso principal que executa o virt-install
resource "null_resource" "vm" {
  triggers = {
    vm_name      = var.name
    memory       = var.memory
    vcpus        = var.vcpus
    disk_path    = var.disk_path
    disk_size_gb = var.disk_size_gb
    iso_path     = var.iso_path
    ip           = var.ip
    network      = var.network
    ks_filename  = local.ks_filename
    ks_content   = local_file.ks.content
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Cria diretório para o disco se não existir
      mkdir -p "$(dirname ${self.triggers.disk_path})"
      # Remove disco antigo, se existir
      rm -f ${self.triggers.disk_path}
      # Executa a instalação
      virt-install --virt-type kvm \
        --name ${self.triggers.vm_name} \
        --memory ${self.triggers.memory} \
        --vcpus ${self.triggers.vcpus} \
        --os-variant ol8.10 \
        --cdrom ${self.triggers.iso_path} \
        --network network=${self.triggers.network},model=virtio \
        --disk path=${self.triggers.disk_path},size=${self.triggers.disk_size_gb} \
        --initrd-inject ${local_file.ks.filename} \
        --extra-args "inst.ks=file:/${self.triggers.ks_filename} console=tty0 console=ttyS0,115200" \
        --noautoconsole
      echo "VM ${self.triggers.vm_name} criada com sucesso."
    EOT
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
      echo "Destruindo VM ${self.triggers.vm_name}..."
      virsh destroy ${self.triggers.vm_name} 2>/dev/null || true
      virsh undefine ${self.triggers.vm_name} --remove-all-storage 2>/dev/null || true
      rm -f ${self.triggers.disk_path}
      echo "VM removida."
    EOT
  }
}

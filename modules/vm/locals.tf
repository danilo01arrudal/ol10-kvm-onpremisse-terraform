locals {
  # Nome do arquivo kickstart gerado
  ks_filename  = "anaconda-ks-${var.name}.cfg"
  root_size_mb = var.root_disk_size * 1024
}


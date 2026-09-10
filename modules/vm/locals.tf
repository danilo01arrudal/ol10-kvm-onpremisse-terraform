locals {
  # Nome do arquivo kickstart gerado
  ks_filename  = "anaconda-ks-${var.name}.cfg"
  root_size_mb = var.disk_size_gb * 1024
}


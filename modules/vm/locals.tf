locals {
  # Calcula o tamanho da partição root subtraindo boot (1024 MB) e swap
  root_size_mb = var.disk_size_mb - 1024 - var.swap_size_mb

  # Nome do arquivo kickstart gerado
  ks_filename = "anaconda-ks-${var.name}.cfg"
}

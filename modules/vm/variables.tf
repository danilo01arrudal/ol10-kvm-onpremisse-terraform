variable "name" {
  description = "Nome da VM"
  type        = string
}

variable "memory" {
  description = "Memória RAM em MB"
  type        = number
}

variable "vcpus" {
  description = "Número de vCPUs"
  type        = number
}

variable "disk_size_gb" {
  description = "Tamanho do disco em GB (usado pelo virt-install)"
  type        = number
}

variable "disk_size_mb" {
  description = "Tamanho do disco em MB (usado no particionamento do kickstart)"
  type        = number
}

variable "swap_size_mb" {
  description = "Tamanho da partição swap em MB"
  type        = number
}

variable "ip" {
  description = "Endereço IP estático"
  type        = string
}

variable "gateway" {
  description = "Gateway da rede"
  type        = string
}

variable "netmask" {
  description = "Máscara de rede"
  type        = string
}

variable "dns" {
  description = "Servidor DNS"
  type        = string
}

variable "hostname" {
  description = "Hostname da VM"
  type        = string
}

variable "iso_path" {
  description = "Caminho para a ISO de instalação"
  type        = string
}

variable "disk_path" {
  description = "Caminho onde o disco da VM será criado"
  type        = string
}

variable "network" {
  description = "Rede libvirt a ser usada"
  type        = string
  default     = "default"
}

variable "timezone" {
  description = "Fuso horário"
  type        = string
  default     = "America/Fortaleza"
}

variable "root_password_hash" {
  description = "Hash da senha do root (gerado com 'openssl passwd -6')"
  type        = string
  sensitive   = true
}

variable "user_name" {
  description = "Nome do usuário não-root"
  type        = string
}

variable "user_password_hash" {
  description = "Hash da senha do usuário"
  type        = string
  sensitive   = true
}

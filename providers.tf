# Configuração dos provedores
# Como usamos apenas recursos locais (local_file, null_resource),
# não há necessidade de configurar provedores com credenciais.
# Este arquivo pode ser usado para configurar backend remoto, se desejado.

# Exemplo de backend remoto para S3 (descomente e ajuste):
# terraform {
#   backend "s3" {
#     bucket = "meu-bucket-terraform"
#     key    = "ol10-kvm-onpremisse-terraform.tfstate"
#     region = "us-east-1"
#   }
# }

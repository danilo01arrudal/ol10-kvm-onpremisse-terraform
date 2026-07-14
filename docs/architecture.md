# Arquitetura do Projeto

## Visão Geral
Este projeto automatiza a criação de VMs Oracle Linux 8.10 em um ambiente on-premisse utilizando Terraform e KVM/libvirt. A arquitetura é baseada em módulos Terraform, permitindo reuso e separação de responsabilidades.

## Componentes Principais

### Terraform
- **versions.tf**: Define a versão do Terraform e dos provedores.
- **providers.tf**: Configura provedores (null, local) e backend remoto (opcional).
- **variables.tf**: Declara variáveis de entrada.
- **locals.tf**: Expressões locais para reuso.
- **main.tf**: Orquestra a chamada ao módulo `vm`.
- **outputs.tf**: Exibe informações úteis após a execução.

### Módulo `vm`
- Encapsula toda a lógica de criação da VM.
- Gera dinamicamente o arquivo de kickstart a partir de um template (Jinja2).
- Executa o `virt-install` via `null_resource` com `local-exec`.

### Kickstart
- Arquivo de configuração para instalação automática do Oracle Linux.
- Define partições, rede, usuários, pacotes e senhas.

### Estrutura de Diretórios
- **environments/**: Separa configurações por ambiente (dev, hom, prd).
- **data/**: Armazena scripts auxiliares e arquivos gerados (kickstart).
- **docs/**: Documentação adicional.

## Fluxo de Execução
1. O usuário define as variáveis no `terraform.tfvars`.
2. O Terraform chama o módulo `vm`.
3. O módulo gera o kickstart e executa o `virt-install`.
4. A VM é criada com a configuração especificada.
5. O estado da VM é gerenciado pelo Terraform.

## Segurança
- Senhas são armazenadas como hashes SHA-512.
- Arquivos sensíveis (como `terraform.tfvars`) são ignorados pelo Git.

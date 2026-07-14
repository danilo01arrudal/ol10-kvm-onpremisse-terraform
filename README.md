# Provisionamento Automatizado de VMs Oracle Linux 8.10 com Terraform em ambiente on-premisse servidor KVM Oracle Linux 10

[![GitHub](https://img.shields.io/badge/Repository-danilo01arrudal/ol10--kvm--onpremisse--terraform-blue?logo=github)](https://github.com/danilo01arrudal/ol10-kvm-onpremisse-terraform)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple?logo=terraform)](https://www.terraform.io/)
[![Oracle Linux](https://img.shields.io/badge/Oracle%20Linux-8.10-red?logo=oracle)](https://www.oracle.com/linux/)
[![KVM](https://img.shields.io/badge/KVM-QEMU-blue?logo=qemu)](https://www.linux-kvm.org/)

## Visão Geral

Este projeto tem como objetivo automatizar a criação de máquinas virtuais com Oracle Linux 8.10 em servidores que utilizam KVM/libvirt, empregando o Terraform como ferramenta de Infrastructure as Code (IaC). A solução foi projetada para ser:

- **Reprodutível**: todo o processo de criação da VM é descrito como código, garantindo consistência entre ambientes.
- **Configurável**: parâmetros como nome, memória, vCPUs, rede e tamanho de disco são facilmente ajustáveis via variáveis.
- **Automatizado**: a instalação do sistema operacional ocorre de forma totalmente desassistida, utilizando um arquivo de kickstart injetado dinamicamente.
- **Modular**: a lógica de criação da VM está encapsulada em um módulo reutilizável, facilitando a manutenção e a evolução do projeto.
- **Integrável**: pode ser facilmente incorporado a pipelines CI/CD ou utilizado em conjunto com outras ferramentas de automação.

## Principais Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| **Criação automatizada de VMs** | Provisiona VMs KVM utilizando o comando `virt-install`. |
| **Instalação desassistida** | Utiliza um arquivo de kickstart (`anaconda-ks.cfg`) gerado dinamicamente a partir de um template. |
| **Configuração de rede estática** | Permite definir IP, gateway, máscara e DNS diretamente nas variáveis do Terraform. |
| **Particionamento flexível** | O esquema de partições (LVM com volumes separados para root e swap) é parametrizado. |
| **Gerenciamento de ciclo de vida** | Suporte completo a `terraform apply` (criação) e `terraform destroy` (remoção da VM e do disco). |
| **Segurança** | As senhas do usuário root e do usuário não-root são configuradas via hashes SHA-512 (gerados com `openssl passwd -6`). |
| **Separação por ambiente** | Estrutura de diretórios que permite configurações distintas para desenvolvimento, homologação e produção. |

---

## 🗂️ Estrutura do Projeto

```plaintext
ol10-kvm-onpremisse-terraform/
├── README.md
├── LICENSE
├── .gitignore
├── terraform.tfvars.example
├── versions.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── modules/
│ └── vm/
│ ├── variables.tf
│ ├── locals.tf
│ ├── main.tf
│ ├── outputs.tf
│ └── templates/
│ └── ks.cfg.tpl
├── data/
│ ├── kickstart/
│ └── scripts/
│ └── generate-hash.sh
├── environments/
│ ├── dev/
│ │ └── terraform.tfvars
│ ├── hom/
│ │ └── terraform.tfvars
│ └── prd/
│ └── terraform.tfvars
└── docs/
├── architecture.md
└── troubleshooting.md
```

---

## 📄 Principais Arquivos e suas Funções

### Raiz do Projeto

| Arquivo | Finalidade |
|---------|------------|
| **versions.tf** | Define as versões mínimas do Terraform e dos provedores necessários. |
| **providers.tf** | Configuração dos provedores (ex: `null`, `local`) e backend remoto (opcional). |
| **variables.tf** | Declaração de todas as variáveis de entrada do projeto (nível raiz). |
| **locals.tf** | Expressões locais para simplificar lógicas e reuso (ex: concatenar caminhos). |
| **main.tf** | Orquestração principal: chama o módulo `vm` com as configurações definidas. |
| **outputs.tf** | Saídas do projeto (ex: nome da VM, IP, caminho do kickstart gerado). |

### Módulo `vm`

| Arquivo | Finalidade |
|---------|------------|
| **modules/vm/variables.tf** | Declaração das variáveis específicas do módulo (memória, vCPUs, rede, etc.). |
| **modules/vm/locals.tf** | Cálculos auxiliares (ex: tamanho da partição root). |
| **modules/vm/main.tf** | Lógica principal: geração do kickstart e execução do `virt-install` via `null_resource`. |
| **modules/vm/outputs.tf** | Saídas específicas do módulo (ex: nome da VM, IP). |
| **modules/vm/templates/ks.cfg.tpl** | Template do kickstart que define partições, rede, usuários e pacotes. |

### Diretórios de Suporte

| Diretório | Finalidade |
|-----------|------------|
| **data/kickstart/** | Armazena os arquivos de kickstart gerados durante a execução. |
| **data/scripts/** | Scripts auxiliares (ex: `generate-hash.sh` para gerar hashes de senha). |
| **environments/** | Configurações específicas por ambiente (dev, hom, prd). Cada um contém seu próprio `terraform.tfvars`. |
| **docs/** | Documentação adicional (arquitetura, solução de problemas, etc.). |

---

## ⚙️ Tecnologias Utilizadas

| Tecnologia | Versão | Finalidade |
|---|---|---|
| Oracle Linux | 10 (servidor host) | Sistema operacional base onde as VMs serão executadas. |
| Oracle Linux | 8.10 (convidado) | Sistema operacional a ser instalado nas VMs. |
| KVM / libvirt | — | Hipervisor e API de gerenciamento de máquinas virtuais. |
| Terraform | >= 1.0 | Ferramenta de Infrastructure as Code para provisionamento. |
| virt-install | — | Utilitário para criação de VMs via linha de comando. |
| Jinja2 | — | Template engine utilizada para gerar o arquivo de kickstart dinamicamente. |

---

## ✅ Pré‑requisitos

Antes de executar o projeto, certifique-se de que:

- O servidor host esteja rodando **Oracle Linux 10** (ou qualquer distribuição com suporte a KVM).
- Os pacotes `qemu-kvm`, `libvirt`, `virt-install` e `terraform` estejam instalados.
- A ISO de instalação do Oracle Linux 8.10 esteja disponível no caminho definido (ex: `/var/lib/libvirt/images/OracleLinux-R8-U10-x86_64-boot-uek.iso`).
- O usuário que executa o Terraform tenha permissão para acessar o libvirt (geralmente via `qemu:///system`) e para escrever no diretório de discos.
- O diretório de discos (ex: `/var/lib/libvirt/images/`) tenha espaço disponível e permissões adequadas.

---

## 🚀 Como Utilizar

#### 1. Clonar o repositório

```bash
git clone https://github.com/danilo01arrudal/ol10-kvm-onpremisse-terraform.git
cd ol10-kvm-onpremisse-terraform
```

#### 2. Configurar as variáveis

Copie o arquivo de exemplo e edite conforme sua necessidade:

```bash
cp terraform.tfvars.example terraform.tfvars
```

No arquivo terraform.tfvars, defina pelo menos:

vm_name: nome desejado para a VM.
ip: endereço IP estático que a VM terá.
iso_path: caminho completo para a ISO de instalação.
disk_path: caminho onde o disco da VM será criado.
Gerando hashes de senha:

Para gerar os hashes das senhas (root e usuário), utilize o script auxiliar:

```bash
./data/scripts/generate-hash.sh "sua_senha"
```

Ou diretamente com openssl:

```bash
openssl passwd -6 "sua_senha"
```

Substitua os valores de root_password_hash e user_password_hash no terraform.tfvars pelos hashes gerados.

#### 3. Inicializar o Terraform

```bash
terraform init
```

#### 4. Planejar e aplicar

Visualize o que será criado:

```bash
terraform plan
```

Execute o provisionamento:

```bash
terraform apply
```

O Terraform irá:

Gerar o arquivo anaconda-ks-<nome_da_vm>.cfg no diretório data/kickstart/.
Executar o virt-install com os parâmetros configurados.
Iniciar a instalação da VM em segundo plano (sem console gráfico).

#### 5. Acompanhar a instalação

Para ver o progresso da instalação, utilize o console da VM:

```bash
virsh console <nome_da_vm>
```

6. Destruir a VM (se necessário)

```bash
terraform destroy
```

Este comando irá:

Parar a VM (se estiver em execução).
Removê-la do libvirt.
Excluir o arquivo de disco associado.

---

## 🌍 Trabalhando com Ambientes

O projeto suporta a separação de configurações por ambiente (desenvolvimento, homologação, produção). Para utilizar um ambiente específico:

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

Cada diretório de ambiente contém seu próprio arquivo terraform.tfvars com as configurações específicas daquele ambiente.

---

## 🔧 Personalização

Alterar parâmetros padrão

Edite o arquivo variables.tf (raiz) para modificar os valores padrão das variáveis (como memória, vCPUs, tamanho do disco, etc.). Para alterar apenas um ambiente, edite o terraform.tfvars correspondente em environments/<ambiente>/.

Modificar o esquema de particionamento

O template do kickstart (modules/vm/templates/ks.cfg.tpl) pode ser ajustado para alterar:

Tamanhos das partições (root, swap, boot).
Sistema de arquivos (atualmente ext4).
Volumes LVM.
Adicionar novos pacotes

No template ks.cfg.tpl, a seção %packages pode ser estendida com pacotes adicionais.

Utilizar uma ISO diferente

Altere a variável iso_path no arquivo terraform.tfvars (ou no ambiente correspondente) para apontar para outra ISO compatível.

---

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests com melhorias, correções ou novas funcionalidades.

---

## 📄 Licença

Este projeto está sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👤 Autor

**Danilo Arruda**  
- GitHub: [@danilo01arrudal](https://github.com/danilo01arrudal)

---

## 🙏 Agradecimentos

- [Oracle Linux pela plataforma estável e confiável](https://www.oracle.com/linux/)
- [Terraform pela poderosa ferramenta de Infrastructure as Code](https://www.terraform.io/)
- [KVM / libvirt pela virtualização de alta performance](https://www.linux-kvm.org/)






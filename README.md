# Provisionamento Automatizado de VMs Oracle Linux 8.10 com Terraform em ambiente on-premisse servidor KVM Oracle Linux 10

## Visão Geral

Este projeto tem como objetivo automatizar a criação de máquinas virtuais com Oracle Linux 8.10 em servidores que utilizam KVM/libvirt, empregando o Terraform como ferramenta de Infrastructure as Code (IaC). A solução foi projetada para ser:

- **Reprodutível**: todo o processo de criação da VM é descrito como código, garantindo consistência entre ambientes.
- **Configurável**: parâmetros como nome, memória, vCPUs, rede e tamanho de disco são facilmente ajustáveis via variáveis.
- **Automatizado**: a instalação do sistema operacional ocorre de forma totalmente desassistida, utilizando um arquivo de kickstart injetado dinamicamente.
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

## 🗂️ Estrutura do Projeto

```
terraform-oraclelinux-vm/
├── main.tf                         # Recurso principal (execução do virt-install)
├── variables.tf                    # Definição de todas as variáveis configuráveis
├── outputs.tf                      # Saídas úteis (nome da VM, IP, etc.)
├── terraform.tfvars.example        # Exemplo de arquivo de variáveis
├── templates/
│   └── ks.cfg.tpl                  # Template do kickstart (partições, rede, usuários)
├── scripts/
│   └── generate-hash.sh            # Utilitário para gerar hashes de senha
└── README.md                       # Este arquivo
```

## 📄 Principais Arquivos e suas Funções

### `main.tf`
Arquivo principal que orquestra a criação da VM. Ele:
- Gera o arquivo `anaconda-ks.cfg` a partir do template `ks.cfg.tpl`.
- Executa o comando `virt-install` com os parâmetros definidos, injetando o kickstart via `--initrd-inject`.
- Utiliza o recurso `null_resource` com `local-exec` para disparar o provisionamento.
- No momento da destruição (`terraform destroy`), remove a VM e o disco associado.

### `variables.tf`
Define todas as variáveis que podem ser customizadas, incluindo:
- Nome da VM, memória, vCPUs.
- Caminhos da ISO e do disco.
- Configurações de rede (IP, gateway, máscara, DNS).
- Tamanhos de partição (root e swap).
- Hashes das senhas (root e usuário).

### `templates/ks.cfg.tpl`
Template em formato Kickstart que:
- Configura a rede com IP estático.
- Define o esquema de particionamento LVM (boot, root, swap).
- Cria o usuário não-root e define a senha do root.
- Utiliza o repositório oficial do Oracle Linux para a instalação dos pacotes.

### `scripts/generate-hash.sh`
Script auxiliar para gerar hashes de senha no formato SHA-512, compatível com o arquivo `/etc/shadow` e com o Kickstart.

## ⚙️ Tecnologias Utilizadas

| Tecnologia | Versão | Finalidade |
|---|---|---|
| Oracle Linux | 10 (servidor host) | Sistema operacional base onde as VMs serão executadas. |
| Oracle Linux | 8.10 (convidado) | Sistema operacional a ser instalado nas VMs. |
| KVM / libvirt | — | Hipervisor e API de gerenciamento de máquinas virtuais. |
| Terraform | >= 1.0 | Ferramenta de Infrastructure as Code para provisionamento. |
| virt-install | — | Utilitário para criação de VMs via linha de comando. |
| Jinja2 | — | Template engine utilizada para gerar o arquivo de kickstart dinamicamente. |

## ✅ Pré‑requisitos

Antes de executar o projeto, certifique-se de que:

- O servidor host esteja rodando **Oracle Linux 10** (ou qualquer distribuição com suporte a KVM).
- Os pacotes `qemu-kvm`, `libvirt`, `virt-install` e `terraform` estejam instalados.
- A ISO de instalação do Oracle Linux 8.10 esteja disponível no caminho definido (ex: `/var/lib/libvirt/images/OracleLinux-R8-U10-x86_64-boot-uek.iso`).
- O usuário que executa o Terraform tenha permissão para acessar o libvirt (geralmente via `qemu:///system`) e para escrever no diretório de discos.
- O diretório de discos (ex: `/var/lib/libvirt/images/`) tenha espaço disponível e permissões adequadas.

## 🚀 Como Utilizar

### 1. Clonar o repositório

```bash
git clone https://github.com/danilo01arrudal/terraform-oraclelinux-vm.git
cd terraform-oraclelinux-vm
```

### 2. Configurar as variáveis

Copie o arquivo de exemplo e edite conforme sua necessidade:

```bash
cp terraform.tfvars.example terraform.tfvars
```

No arquivo `terraform.tfvars`, defina pelo menos:

- `vm_name`: nome desejado para a VM.
- `ip`: endereço IP estático que a VM terá.
- `iso_path`: caminho completo para a ISO de instalação.
- `disk_path`: caminho onde o disco da VM será criado.

**Gerando hashes de senha:**

Para gerar os hashes das senhas (root e usuário), utilize o script auxiliar:

```bash
./scripts/generate-hash.sh "sua_senha"
```

Ou diretamente com `openssl`:

```bash
openssl passwd -6 "sua_senha"
```

Substitua os valores de `root_password_hash` e `user_password_hash` no `terraform.tfvars` pelos hashes gerados.

### 3. Inicializar o Terraform

```bash
terraform init
```

### 4. Planejar e aplicar

Visualize o que será criado:

```bash
terraform plan
```

Execute o provisionamento:

```bash
terraform apply
```

O Terraform irá:
- Gerar o arquivo `anaconda-ks.cfg` na raiz do projeto.
- Executar o `virt-install` com os parâmetros configurados.
- Iniciar a instalação da VM em segundo plano (sem console gráfico).

### 5. Acompanhar a instalação

Para ver o progresso da instalação, utilize o console da VM:

```bash
virsh console <nome_da_vm>
```

### 6. Destruir a VM (se necessário)

```bash
terraform destroy
```

Este comando irá:
- Parar a VM (se estiver em execução).
- Removê-la do libvirt.
- Excluir o arquivo de disco associado.

## 🔧 Personalização

### Alterar parâmetros padrão

Edite o arquivo `variables.tf` para modificar os valores padrão das variáveis (como memória, vCPUs, tamanho do disco, etc.).

### Modificar o esquema de particionamento

O template do kickstart (`templates/ks.cfg.tpl`) pode ser ajustado para alterar:
- Tamanhos das partições (root, swap, boot).
- Sistema de arquivos (atualmente ext4).
- Volumes LVM.

### Adicionar novos pacotes

No template `ks.cfg.tpl`, a seção `%packages` pode ser estendida com pacotes adicionais.

### Utilizar uma ISO diferente

Altere a variável `iso_path` no arquivo `terraform.tfvars` para apontar para outra ISO compatível.

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests com melhorias, correções ou novas funcionalidades.

## 📜 Licença

Este projeto está sob a licença MIT. Consulte o arquivo [LICENSE](https://github.com/danilo01arrudal/terraform-oraclelinux-vm/blob/main/LICENSE) para mais detalhes.

## 👤 Autor

**Danilo Arruda**

## 🙏 Agradecimentos

- [Oracle Linux](https://www.oracle.com/linux/) pela plataforma estável e confiável.
- [Terraform](https://www.terraform.io/) pela poderosa ferramenta de Infrastructure as Code.
- [KVM / libvirt](https://www.linux-kvm.org/) pela virtualização de alta performance.
- [PostgreSQL Global Development Group](https://www.postgresql.org/) (inspiração para a estrutura do README).


---

Esse `README.md` segue a mesma estrutura, tom e nível de detalhamento do repositório de referência, adaptado para o contexto do seu projeto Terraform. Ele cobre desde a visão geral até instruções práticas de uso, personalização e contribuição.

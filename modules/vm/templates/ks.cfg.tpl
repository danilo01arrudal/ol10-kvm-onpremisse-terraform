#version=OL8

# Instalação autônoma em modo texto
text
cmdline
skipx

# Utiliza a própria ISO DVD montada pelo virt-install como fonte de pacotes
cdrom

%packages
@^minimal-environment
kexec-tools
%end

# Layout de teclado e linguagem
keyboard --xlayouts='us'
lang en_US.UTF-8

# Configuração de Rede Estática
network --bootproto=static --device=enp1s0 --gateway=${gateway} --ip=${ip} --nameserver=${dns} --netmask=${netmask} --noipv6 --activate
network --hostname=${hostname}

# Desativa o assistente no primeiro boot
firstboot --disable

# Configuração do Bootloader (BIOS)
bootloader --location=mbr --boot-drive=vda

ignoredisk --only-use=vda
clearpart --all --initlabel   # Limpa partições existentes

# Particionamento do Disco
part biosboot --fstype="biosboot" --ondisk=vda --size=2
part /boot --fstype="ext4" --ondisk=vda --size=1024
part pv.610 --fstype="lvmpv" --ondisk=vda --grow

volgroup ol --pesize=4096 pv.610
logvol / --fstype="ext4" --grow --size=1024 --name=root --vgname=ol
logvol swap --fstype="swap" --size=${swap_size_mb} --name=swap --vgname=ol

# Fuso Horário
timezone ${timezone} --isUtc

# Senhas de Root e Usuário
rootpw --iscrypted ${root_password_hash}
user --groups=wheel --name=${user_name} --password=${user_password_hash} --iscrypted --gecos="${user_name}"

# Aceita licença de uso
eula --agreed

%addon com_redhat_kdump --disable --reserve-mb='auto'
%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

# Reinicia e ejeta o DVD automaticamente ao finalizar
reboot --eject

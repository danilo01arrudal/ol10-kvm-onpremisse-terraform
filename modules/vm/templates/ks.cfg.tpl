#version=OL8
# Use graphical install
graphical

%packages
@^minimal-environment
@standard
%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=enp1s0 --gateway=${gateway} --ip=${ip} --nameserver=${dns} --netmask=${netmask} --noipv6 --activate
network  --hostname=${hostname}

# Use network installation
# url --url="https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/"   # REMOVIDO - usando mídia local

# Run the Setup Agent on first boot
firstboot --enable

# Bootloader configuration (BIOS mode)
bootloader --location=mbr --boot-drive=vda

ignoredisk --only-use=vda
clearpart --all --initlabel   # Limpa todas as partições existentes

# Disk partitioning with BIOS boot partition
part biosboot --fstype="biosboot" --ondisk=vda --size=2
part /boot --fstype="ext4" --ondisk=vda --size=1024
part pv.610 --fstype="lvmpv" --ondisk=vda --grow          # PV ocupa o restante do disco

volgroup ol --pesize=4096 pv.610
logvol / --fstype="ext4" --grow --size=1024 --name=root --vgname=ol   # Root cresce automaticamente
logvol swap --fstype="swap" --size=${swap_size_mb} --name=swap --vgname=ol

# System timezone
timezone ${timezone} --isUtc

# Root password
rootpw --iscrypted ${root_password_hash}
user --groups=wheel --name=${user_name} --password=${user_password_hash} --iscrypted --gecos="${user_name}"

%addon com_redhat_kdump --disable --reserve-mb='auto'
%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

# Reinicia automaticamente após a instalação
reboot

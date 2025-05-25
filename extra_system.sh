#!/bin/sh
export HOST_NAME
if [[ -z "${HOST_NAME+x}" ]]; then
  echo "Set HOST_NAME enviroment variable"
  exit
fi

export GPU
if [[ -z "${GPU+x}" ]]; then
  echo "Set GPU environment variable. Supported values: NV or AMD"
fi

if [[ "$GPU" != "NV" && "$GPU" != "AMD" ]]; then
  echo "GPU is neither NV nor AMD"
fi

export GAMING

# Set Localtime
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

#Set locale
sed -i 's/#pt_BR.UTF-8/pt_BR.UTF-8/g' /etc/locale.gen
locale-gen
echo LANG=pt_BR.UTF-8 >>/etc/locale.conf

#Set HostName
echo $HOST_NAME >>/etc/hostname
sed -i "s/myhostname/${HOST_NAME}/g" /etc/hosts

#Hook limine
mkdir -p /etc/pacman.d/hooks/
cat <<EOF | tee /etc/pacman.d/hooks/99-limine.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = limine

[Action]
Description = Deploying Limine after upgrade...
When = PostTransaction
Exec = /usr/bin/cp /usr/share/limine/BOOTX64.EFI boot/efi/EFI/limine/
EOF

# Install CachyOS Kernel and Repo
cd /root
curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
cd cachyos-repo
./cachyos-repo.sh
rm -r /root/cachyos-repo /root/cachyos-repo.tar.xz

# Rate mirrors
pacman -Sy --noconfirm cachyos-rate-mirrors
cachyos-rate-mirrors

#Install packages
pacman -Syyu --noconfirm \
  efibootmgr \
  mkinitcpio \
  linux-cachyos \
  linux-cachyos-headers \
  linux-firmware \
  networkmanager \
  wpa_supplicant \
  network-manager-applet \
  reflector \
  git \
  bluez \
  blueman \
  bluez-utils \
  xdg-utils \
  xdg-user-dirs \
  cups \
  dosfstools \
  e2fsprogs \
  lvm2 \
  foomatic-db-engine \
  foomatic-db \
  btrfs-progs \
  paru \
  intel-ucode \
  amd-ucode \
  stow \
  firewalld \
  snapper \
  snap-pac \
  chwd
if [[ GAMING -eq 1 ]]; then
  pacman -S --noconfirm cachyos-gaming-meta
fi

mkinitcpio -p linux-cachyos
mkdir -p /etc/mkinitcpio.conf.d
echo "MODULES+=(btrfs)" >>/etc/mkinitcpio.conf.d/0-btrfs.conf
chwd -a
mkinitcpio -P

echo "Finished installing kernel, firewall and extra packages"
exit

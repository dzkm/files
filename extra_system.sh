#!/bin/sh
export HOST_NAME;
if [[ HOST_NAME == "" ]]; then
  echo "Set HOST_NAME enviroment variable";
  exit()
fi

export GAMING;

# Set Localtime
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime;
hwclock --systohc

#Set locale
sed 's/#pt_BR.UTF-8/pt_BR.UTF-8/g' /etc/locale.gen;
locale-gen;
echo LANG=pt_BR.UTF-8 >> /etc/locale.conf;

#Set HostName
echo $HOST_NAME >> /etc/hostname;
sed `s/myhostname/$HOST_NAME/g` /etc/hosts;

# Install CachyOS Kernel and Repo
cd /root;
curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz;
tar xvf cachyos-repo.tar.xz;
cd cachyos-repo;
./cachyos-repo.sh;
rm -r /root/cachyos-repo /root/cachyos-repo.tar.xz;

#Install packages
pacman -Syyu --no-confirm grub \
  efibootmgr \
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
  buez-utils \
  xdg-utils \
  xdg-user-dirs \
  cups \
  dosfstools \
  e2fsprogs \
  lvm2 \
  foomatic-db-engine \
  foomatic-db \
  grub-btrfs \
  btrfs-progs \
  paru \
  intel-ucode \
  amd-ucode \
  stow
if [[ GAMING == 1]]; then
  pacman -S --no-confirm cachyos-gaming-meta
fi;

echo "Edit /etc/mkinitcpio.conf to add the modules then run mkinitcpio -P 
BTRFS – btrfs
Intel GPU - i915
AMD GPU – amdgpu
NVIDIA Driver – nvidia nvidia_modeset nvidia_uvm nvidia_drm
Nouveau Driver – nouveau
EXT4 - ext4
XFS - xfs";
exit();

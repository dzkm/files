#!/bin/sh

if [[ $(cat /etc/hostname) != 'archiso' ]]; then
  echo "This script should only be run on archiso"
  exit
fi

export ROOT_DEVICE
if [[ -z "${ROOT_DEVICE+x}" ]]; then
  echo "Supply ROOT_DEVICE environment variable"
  exit
fi

#VARIABLES
TOTAL_RAM_KB=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
EFI_START="1MiB"
EFI_END="1025MiB"

SWAP_PERCENTAGE=60
SWAP_CALCULATED_MB="${TOTAL_RAM_MB}"
if [[ "${SWAP_CALCULATED_MB}" -gt 16384 ]]; then
  SWAP_CALCULATED_MB=$((TOTAL_RAM_MB * SWAP_PERNCETAGE / 100))
fi
SWAP_START="${EFI_END}"
SWAP_END="$((SWAP_CALCULATED_MB + $(echo "$SWAP_START" | sed 's/MiB//g')))MiB"
BTRFS_START=${SWAP_END}

#INFO DUMP
echo "RAM: ${TOTAL_RAM_MB}MiB"
echo "SWAP: ${SWAP_CALCULATED_MB}MiB"

#SET LOCALE
loadkeys br-abnt2
timedatectl set-timezone America/Sao_Paulo

#CLEAR DEVICE
dd if=/dev/zero of="${ROOT_DEVICE}" bs=32M status=progress
parted -s "$ROOT_DEVICE" mklabel gpt

#EFI
parted -s "$ROOT_DEVICE" mkpart "EFI" fat32 "${EFI_START}" "${EFI_END}"
parted -s "$ROOT_DEVICE" set 1 esp on
#SWAP
parted -s "$ROOT_DEVICE" mkpart "SWAP" linux-swap "${SWAP_START}" "${SWAP_END}"
parted -s "$ROOT_DEVICE" set 2 swap on
#BTRFS
parted -s "$ROOT_DEVICE" mkpart "BTRFS" btrfs "${BTRFS_START}" 100%

if [[ $? -ne 0 ]]; then
  echo "Something went wrong."
  exit 1
fi

#MAKE FILESYSTEM
PARTED_DEVICE=$ROOT_DEVICE
if [[ $ROOT_DEVICE == *"nvme"* ]]; then
  PARTED_DEVICE="${ROOT_DEVICE}p"
fi

mkfs.fat -F 32 "${PARTED_DEVICE}1"
mkswap "${PARTED_DEVICE}2"
mkfs.btrfs -f "${PARTED_DEVICE}3"

export BTRFS_DEVICE="${PARTED_DEVICE}3"
sh ./btrfs_volumes.sh

mkdir /mnt/boot
mount "${PARTED_DEVICE}1" /mnt/boot
pacstrap /mnt base base-devel vim limine
genfstab -U /mnt >>/mnt/etc/fstab

#Setup limine
mkdir -p /mnt/boot/efi/EFI/limine
mkdir -p /mnt/boot/limine
cp /mnt/usr/share/limine/BOOTX64.EFI /mnt/boot/efi/EFI/limine
efibootmgr \
  --create \
  --disk "${ROOT_DEVICE}" \
  --part 1 \
  --label "Arch Linux Limine Bootloader" \
  --loader '\EFI\limine\BOOTX64.EFI' \
  --unicode \
  --verbose

cat <<EOF | tee /mnt/boot/limine/limine.conf
timeout: 5
/Arch Linux
  protocol: linux
  path: boot():/vmlinuz-linux-cachyos
  cmdline: root=UUID=$(blkid "${PARTED_DEVICE}3" -s UUID -o value) rw rootflags=subvol=/@
  module_path: boot():/initramfs-linux
EOF

echo "Base system installed. But not kernel yet."
echo "You can copy extra_system.sh to /mnt/root and execute it."
echo "To execute, just run: arch-chroot /mnt /bin/bash /root/extra_system.sh"
exit

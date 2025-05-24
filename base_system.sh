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
TOTAL_RAM_KB=$(grep "MemTotal" /proc/meminfo | awk {print $2})
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
EFI_START="1MiB"
EFI_END="1025MiB"

SWAP_PERCENTAGE=60
SWAP_CALCULATED_MB="${TOTAL_RAM_MB}"
if ( (SWAP_CALCULATED_MB >16384)); then
  SWAP_CALCULATED_MB=$((TOTAL_RAM_MB * SWAP_PERNCETAGE / 100))
fi
SWAP_START="${EFI_END}"
SWAP_END="$((SWAP_CALCULATED_MB + $(echo "$SWAP_START" | sed 's/MiB//g')))MiB"
BTRFS_START=${SWAP_END}

#INFO DUMP
echo "RAM: ${TOTAL_RAM_MB}MiB"
echo "SWAP: ${SWAP_SIZE_PARTED}MiB"

#SET LOCALE
loadkeys br-abnt2
timedatectl set-timezone America/Sao_Paulo

#CLEAR DEVICE
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
pacstrap /mnt base base-devel vim
genfstab -U /mnt >>/mnt/etc/fstab
echo "Check generated fstab to see if there's any repeated entries and if they don't have noatime"
exit

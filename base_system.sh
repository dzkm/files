#!/bin/sh

if [[ $(cat /etc/hostname) != 'archiso' ]]; then
  echo "This script should only be run on archiso";
  exit;
fi

export ROOT_DEVICE;
if [[ ROOT_DEVICE == "" ]]; then
  echo "Supply ROOT_DEVICE environment variable"
  exit
fi

#VARIABLES
TOTAL_RAM_MB=$(((grep "MemTotal" /proc/meminfo | awk {print $2}) / 1024));
EFI_START="1MiB";
EFI_END="1025MiB";

SWAP_CALCULATED_MB=$((TOTAL_RAM_MB * 60 / 100));
if [[ SWAP_CALCULATED_MB > 16384 ]]; then
  SWAP_CALCULATED_MB=16384;
fi
SWAP_START="${EFI_END}";
SWAP_END=$((SWAP_CALCALATED_MB + $(echo "$SWAP_START" | sed 's/MiB//g'))) + "MiB";
BTRFS_START=${SWAP_END};


#INFO DUMP
echo "RAM: ${TOTAL_RAM_MB}MiB";
echo "SWAP: ${SWAP_SIZE_PARTED}MiB";

#SET LOCALE
loadkeys br-abnt2;
timedatectl set-timezone America/Sao_Paulo;

#CLEAR DEVICE
parted -s "$ROOT_DEVICE" mklabel gpt;

#EFI
parted -s "$ROOT_DEVICE" mkpart "EFI" fat32 "${EFI_START}" "${EFI_END}";
parted -s "$ROOT_DEVICE" set 1 esp on;
#SWAP
parted -s "$ROOT_DEVICE" mkpart "SWAP" linux-swap "${SWAP_START}" "${SWAP_END}";
parted -s "$ROOT_DEVICE" set 2 swap on;
#BTRFS
parted -s "$ROOT_DEVICE" mkpart "BTRFS" btrfs "${BTRFS_START}" 100%;

#MAKE FILESYSTEM
PARTED_DEVICE=$ROOT_DEVICE;
if [[ $ROOT_DEVICE == *"nvme"* ]]; then
  PARTED_DEVICE="${ROOT_DEVICE}p";
fi
if [[ $? -neq 0 ]]; then
  echo "Something went wrong.";
  exit 1;
fi

mkfs.fat -F 32 "${PARTED_DEVICE}1";
mkswap "${PARTED_DEVICE}2";
mkfs.btrfs "${PARTED_DEVICE}3";

sh ./btrfs_volumes.sh

mkdir /mnt/boot
mount $EFI_DEVICE /mnt/boot
pacstrap /mnt base base-devel vim
genfstab -U /mnt >>/mnt/etc/fstab
echo "Check generated fstab to see if there's any repeated entries and if they don't have noatime"
exit

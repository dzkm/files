#!/bin/sh

export EFI_DEVICE
if [[ EFI_DEVICE == "" ]]; then
  echo "Supply EFI_DEVICE environment variable"
  exit
fi

sh ./btrfs_volumes.sh

mkdir /mnt/boot
mount $EFI_DEVICE /mnt/boot
pacstrap /mnt base base-devel vim
genfstab -U /mnt >>/mnt/etc/fstab
echo "Check generated fstab to see if there's any repeated entries and if they don't have noatime"
exit

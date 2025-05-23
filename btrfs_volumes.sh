#!/bin/sh
export BTRFS_DEVICE
if [ BTRFS_DEVICE == "" ]; then
  echo "Add BTRFS_DEVICE=/dev/root_device lol"
  exit
fi

# Mount volume
mount $BTRFS_DEVICE /mnt

# Create btrfs subvolumes
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@root
btrfs su cr /mnt/@srv
btrfs su cr /mnt/@var

# Mount them:
cd /root
umount /mnt
mount -o defaults,noatime,compress=zstd,commit=120,space_cache=v2,subvol=@ $BTRFS_DEVICE /mnt
mkdir /mnt/{boot,home,opt,tmp,snapshots,root,srv,var}
mount -o defaults,noatime,compress=zstd,commit=120,space_cache=v2,subvol=@home $BTRFS_DEVICE /mnt/home
mount -o defaults,noatime,compress=zstd,commit=120,space_cache=v2,subvol=@opt $BTRFS_DEVICE /mnt/opt
mount -o defaults,noatime,compress=zstd,commit=120,space_cache=v2,subvol=@tmp $BTRFS_DEVICE /mnt/tmp
mount -o defaults,noatime,compress=zstd,commit=120,space_cache=v2,subvol=@snapshots $BTRFS_DEVICE /mnt/snapshots
mount -o defaults,noatime,compress=zstd,commit=120,space_cache=v2,subvol=@root $BTRFS_DEVICE /mnt/root
mount -o defaults,noatime,compress=zstd,commit=120,space_cache=v2,subvol=@srv $BTRFS_DEVICE /mnt/srv
mount -o defaults,noatime,compress=zstd,commit=120,space_cache=v2,subvol=@var $BTRFS_DEVICE /mnt/var
mount -o subvol=@var $BTRFS_DEVICE /mnt/var

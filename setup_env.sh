#!/bin/sh

if [[ $(whoami) != "root" ]]; then
  echo "Run as root"
  exit
fi

# Install CachyOS repositories
curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
./cachyos-repo/cachyos-repo.sh
rm -r cachyos-repo cachyos-repo.tar.xz

# Getting CachyOS pacman
pacman -S --noconfirm paru
paru -S --noconfirm cachyos/pacman

# Get faster mirrors
pacman -S reflector
reflector --sort rate --latest 20 --protocol https --save /etc/pacman.d/mirrorlist

# More parallel downloads
sed -i "s/ParallelDownloads = 5/ParallelDownloads = 15/g" /etc/pacman.conf

# Install Chaotic AUR
pacman-key --noconfirm --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --noconfirm --lsign-key 3056513887B78AEB
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
cat <<EOF | tee -a /etc/pacman.conf

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

pacman -Sy

# Install CachyOS Kernel
paru -S limine-mkinitcpio-hook
pacman -S linux-cachyos linux-cachyos-headers

# Remove unwanted packages
pacman -Rm --noconfirm dolphin ufw

# Install my packages
paru -S --noconfirm --needed - <./packages.txt

# Install wallrizz
curl -L $(curl -s https://api.github.com/repos/5hubham5ingh/WallRizz/releases/latest | grep -oP '"browser_download_url": "\K(.*)(?=")' | grep WallRizz) -o WallRizz.tar
tar -xzf WallRizz.tar
mv WallRizz /usr/bin/

# Install wofi-moji
curl https://raw.githubusercontent.com/Zeioth/wofi-emoji/master/wofi-emoji -o /usr/bin/wofi-emoji

# Install fzf-lua
sh -c "$(curl -s https://raw.githubusercontent.com/ibhagwan/fzf-lua/main/scripts/mini.sh)"

# Installing fonts
mkdir -p /usr/local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip
unzip FiraCode.zip -d /usr/local/share/fonts/FiraCode/

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Noto.zip
unzip Noto.zip -d /usr/local/share/fonts/Noto/

rm FiraCode.zip Noto.zip
fc-cache

# Flatpak packages
flatpak install -y dev.vencord.Vesktop com.github.tchx84.Flatseal org.ferdium.Ferdium com.bitwarden.desktop org.localsend.localsend_app io.dbeaver.DBeaverCommunity

# Start services
systemctl enable --now bluetooth.service firewalld.service power-profiles-daemon.service gnome-keyring-daemon docker

# Start UWSM services
userMain=$(cat /etc/passwd | grep 1000:1000 | awk -F ":" '{print $1}')
su - "${userMain}" -c "systemctl --user enable \
  waybar.service \
  hyprlock.service \
	hypridle.service \
	hyprpolkitagent.service"

# Add user to docker and set shell to zsh
usermod -aG docker --shell /bin/zsh $userMain

#TODO: Add stow for dotfiles

echo "Done installing. Reboot computer"

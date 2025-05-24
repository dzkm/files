#!/bin/sh
export NVIDIA;

sudo systemctl enable NetworkManager bluetooth org.cups.cupsd;

# Install WM
paru -S --no-confirm hyprland \
  uwsm \
  pyxdg \
  dbug_python \
  util-linux \
  whiptail \
  wofi \
  libnotify-bin \
  greetd-regreet
if [[ NVIDIA == 1]]; then
  echo "options nvidia_drm modeset=1" >> /etc/modprobe.d/nvidia.conf
fi
cat << EOF
exec-once = regreet; hyprctl dispatch exit
misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    disable_hyprland_qtutils_check = true
}
EOF >> /etc/greed/hyprland.conf;




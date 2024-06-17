#!/bin/sh
current_dir = $(pwd)
home_config_dir = "$HOME/.config"

if [  ! -d "$home_config_dir/kitty" ]; then
    mkdir -p $home_config_dir/kitty
fi
mv $home_config_dir/kitty/kitty.conf $home_config_dir/kitty/kitty.conf.bak
ln -s $current_dir/kitty.conf $home_config_dir/kitty/kitty.conf

mv $HOME/.tmux.conf $HOME/.tmux.conf.bak
ln -s $current_dir/.tmux.conf $HOME/.tmux.conf

if [ ! -d "$home_config_dir/sheldon" ]; then
    mkdir -p $home_config_dir/sheldon
fi
mv $home_config_dir/sheldon/plugins.toml $home_config_dir/sheldon/plugins.toml.bak
ln -s $current_dir/sheldon-plugins.toml $home_config_dir/sheldon/plugins.toml

if [ ! -d "$home_config_dir/nvim" ]; then
    mkdir -p $home_config_dir/nvim
fi
mv $home_config_dir/nvim $home_config_dir/nvim_bak
ln -s $current_dir/nvim $home_config_dir/nvim

mv $HOME/.zshrc $HOME/.zshrc.bak
ln -s $current_dir/.zshrc $HOME/.zshrc


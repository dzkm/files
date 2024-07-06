eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/catppuccin_mocha.omp.json)"
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=5000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/dzkm/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

#custom
alias neofetch="fastfetch"
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
export PATH="${PATH:+${PATH}:}$HOME/.local/bin"

zle -N menu-search
zle -N recent-paths
zle -N insert-unambiguous-or-complete

eval `keychain --eval github-pop.dfms`

bindkey "^[[3~" delete-char

# Load Sheldon
eval "$(sheldon source)"


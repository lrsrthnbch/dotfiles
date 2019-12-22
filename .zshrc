# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/lars/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

#PROMPT="%F{red}%n%f%F{yellow}@%f%F{green}%m%f:%F{cyan}%~%f%F{green}$ %f"
PROMPT="%F{blue}%~%f%F{magenta} > %f"
alias dotfiles='/usr/bin/git --git-dir=/home/lars/.dotfiles/ --work-tree=/home/lars'



# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -l -h'
alias icat='kitty +kitten icat'

# default mime application opener
alias open='xdg-open'

COLOR1="$(tput setaf 10)"
COLOR2="$(tput setaf 3)"
COLOR3="$(tput setaf 6)"
RESET="$(tput sgr0)"
BLINK="$(tput blink)"

powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/share/powerline/bindings/bash/powerline.sh

triangle=$'\uE0B0'


PS1='\[$COLOR1\] \# [\A \[$COLOR3\]\W \[$COLOR1\]] \[$COLOR2\] $triangle \[$RESET\]'


[ -z $DISPLAY ] && [ $(tty) = /dev/tty1 ] && startx

source <(kitty + complete setup bash)


# /usr/bin/prime-switch




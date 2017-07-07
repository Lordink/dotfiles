[ -n "$PS1" ] && source ~/.bash_profile

alias vi="vim"
alias vscode="code"
alias vs="code"
alias moon="cd ~/Code/moonshine && git status"
eval $( dircolors -b ~/LS_COLORS/LS_COLORS )
paci() {
    sudo pacman -S "$1"
}

# [ -f ~/.fzf.bash ] && source ~/.fzf.bash

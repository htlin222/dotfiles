if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND="fd --type f"
    export FZF_DEFAULT_OPTS='--color=bg+:#293739,bg:#1B1D1E,border:#808080,spinner:#E6DB74,hl:#7E8E91,fg:#F8F8F2,header:#7E8E91,info:#A6E22E,pointer:#A6E22E,marker:#F92672,fg+:#F8F8F2,prompt:#F92672,hl+:#F92672 -m --height 80% --layout=reverse --inline-info'

fi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

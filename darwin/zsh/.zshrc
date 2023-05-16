# exports
export PATH="/Users/opus/.local/bin:$PATH"
export PATH="$PATH:/usr/local/opt/llvm/bin/"
export PATH="$PATH:/usr/local/opt/riscv-gnu-toolchain/bin"
export PATH=$HOME/bin:$PATH
export PATH=$PATH:$GOPATH/bin/
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$PATH:$HOME/dotfiles/home/bin/"

export ZSH="/Users/opus/.oh-my-zsh"
export GOPATH=$HOME/go
export AIRPLANE_INSTALL="/Users/opus/.airplane"
export PATH="$AIRPLANE_INSTALL/bin:$PATH"
export GPG_TTY=$(tty)

# Emojis suck ass
export MINIKUBE_IN_STYLE=false
export K9S_NO_EMOJI=1

# FZF colors: Generated from https://minsw.github.io/fzf-color-picker/
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=fg:#a8a3b3,bg:#faf4ed,hl:#a8a3b3 --color=fg+:#575279,bg+:#ebe5df,hl+:#575279 --color=info:#9893a5,prompt:#b4637a,pointer:#907aa9 --color=marker:#d7827e,spinner:#907aa9,header:#87afaf'

# Enable colors and change prompt:
# sindresorhus/pure: https://github.com/sindresorhus/pure
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

plugins=(
	z
	tmux
	zsh-autosuggestions
	zsh-syntax-highlighting
	docker
	docker-compose
)


source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

# general aliases
alias o="xdg-open"
alias k="kubectl"
alias kd="kubectl describe"
alias kg="kubectl get"
alias kgy="kubectl get -o yaml"
alias vim="nvim"
alias tn="tmux new -s"
alias tl="tmux ls"
alias ta="tmux attach"
alias zshconfig="vim ~/.zshrc"
alias vimconfig="vim ~/.config/nvim/init.lua"
alias dotfiles="cd ~/dotfiles"
alias ytd="youtube-dl --verbose -f best -o '%(title)s.%(ext)s'"
alias dps="docker ps --format 'table {{ .ID }}\t{{.Names}}\t{{.Status}}'"
alias helm="helm --debug"
alias untar="tar xvzf"

# git aliases
alias gc="git commit -v"
alias gst="git status --short"
alias ga="git add"
alias gd="git diff --minimal"
alias gl="git log --oneline --decorate --graph"
alias gdc="git diff --cached"
alias gcan="git commit --amend --no-edit"

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Yank to the system clipboard
function vi-yank-xclip {
    zle vi-yank
   echo "$CUTBUFFER" | pbcopy -i
}

zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-xclip

# open in editor
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd " " edit-command-line

# ctrl+r search history
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/opus/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/opus/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/opus/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/opus/google-cloud-sdk/completion.zsh.inc'; fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

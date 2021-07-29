# exports
export PATH="/Users/opus/.local/bin:$PATH"
export ZSH="/Users/opus/.oh-my-zsh"
export PATH=$HOME/bin:$PATH
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin/


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
)


source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

# general aliases
alias o="xdg-open"
alias k="kubectl"
alias vim="nvim"
alias tn="tmux new -s"
alias tl="tmux ls"
alias ta="tmux attach"
alias zshconfig="vim ~/.zshrc"
alias vimconfig="vim ~/.config/nvim/init.vim"
alias dotfiles="cd ~/dotfiles"
alias ytd="youtube-dl --verbose -f best -o '%(title)s.%(ext)s'"

# git aliases
alias gc="git commit -v"
alias gst="git status --short"
alias ga="git add"
alias gd="git diff --minimal"
alias gl="git log --oneline --decorate --graph"

# vi mode
bindkey -v
export KEYTIMEOUT=1

# ctrl+r search history
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/opus/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/opus/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/opus/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/opus/google-cloud-sdk/completion.zsh.inc'; fi

# pyenv things
eval "$(pyenv init -)"


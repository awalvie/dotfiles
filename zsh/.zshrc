# ohmyzsh defaults
export ZSH="/Users/tinker/.oh-my-zsh"

# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%1d%{$fg[red]%}]%{$reset_color%}$%b "

plugins=(
	z
	git
	tmux
	vi-mode
	zsh-autosuggestions
	zsh-syntax-highlighting
)


source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

alias k="kubectl"
alias vim="nvim"
alias tn="tmux new -s"
alias zshconfig="vim ~/.zshrc"
alias vimconfig="vim ~/dotfiles/nvim/.config/nvim/init.vim"
alias dotfiles="cd ~/dotfiles"

# ctrl+r search history
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# custom exports
export GOPATH=$HOME/go
export PATH=$PATH:~/go/bin/
export PATH="$HOME/.pyenv/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/tmp/trash/google-cloud-sdk/path.zsh.inc' ]; then . '/tmp/trash/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/tmp/trash/google-cloud-sdk/completion.zsh.inc' ]; then . '/tmp/trash/google-cloud-sdk/completion.zsh.inc'; fi

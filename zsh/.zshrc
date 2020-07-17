# ohmyzsh defaults
export ZSH="/home/awalvie/.oh-my-zsh"

# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%1d%{$fg[red]%}]%{$reset_color%}$%b "

plugins=(
	git
	tmux
	vi-mode
	zsh-autosuggestions
	zsh-syntax-highlighting
)


source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

alias zshconfig="vim ~/.zshrc"
alias open="xdg-open"
alias bigtree="cd ~/github/bigtree; poetry shell"
alias r="ranger"
alias vimconfig="vim ~/dotfiles/nvim/.config/nvim/init.vim"
alias expcon="expressvpn connect"
alias expdis="expressvpn disconnect"
alias lyceum="cd ~/github/lyceum/; vim ."

# ctrl+r search history
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh

# preview markdown files
unalias md
md() { pandoc "$1" | lynx -stdin; }

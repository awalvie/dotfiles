# ohmyzsh defaults
export ZSH="~/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

plugins=(
	git
	tmux
	vi-mode
	zsh-autosuggestions
	zsh-syntax-highlighting
)


source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='vim'
 fi

# enable vim mode in terminal
bindkey -v

alias zshconfig="vim ~/.zshrc"
alias open="xdg-open"
alias r="ranger"
alias vimconfig="vim ~/dotfiles/nvim/.config/nvim/init.vim"

# ctrl+r search history
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

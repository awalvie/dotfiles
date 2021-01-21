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
alias vimconfig="vim ~/dotfiles/nvim/.config/nvim/init.vim"
alias lyceum="cd ~/projects/github/lyceum/"
alias serve_ly="cd ~/projects/github/sersim/src; ./main -l '/home/awalvie/projects/github/lyceum/docs/' -p 8080"
alias free_time="xdg-open ~/Desktop/art_related/art_books/'Instructional Books'/"
alias dotfiles="cd ~/dotfiles"
alias sendpost="cd ~/go/src/github.com/sendx"

# taskwarrior aliases
alias in="task add +in"
alias tasks='task +next'

alias tmd='task modify'

# ctrl+r search history
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# custom exports
export GOPATH=$HOME/go
export PATH=$PATH:~/go/bin/
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
source /usr/local/bin/virtualenvwrapper_lazy.sh

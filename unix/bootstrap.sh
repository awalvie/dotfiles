
#!/bin/bash

# Exit on error, undefined variable, or failed pipe
set -euo pipefail

LOGFILE="/tmp/bootstrap.log"

# Check for root privileges
require_root() {
	if [[ $EUID -ne 0 ]]; then
		echo "Please run as root (sudo $0)" | tee -a "$LOGFILE"
		exit 1
	fi
}

# Update package lists
update_packages() {
	echo "Updating package lists..." | tee -a "$LOGFILE"
	apt-get update -y | tee -a "$LOGFILE"
}

# Install a package if not present
install_package() {
	local pkg="$1"
	if ! command -v "$pkg" &>/dev/null; then
		echo "Installing $pkg..." | tee -a "$LOGFILE"
		apt-get install -y "$pkg" | tee -a "$LOGFILE"
	else
		echo "$pkg already installed." | tee -a "$LOGFILE"
	fi
}

# Install all packages from a list
install_packages() {
	local pkgs=("$@")
	for pkg in "${pkgs[@]}"; do
		install_package "$pkg"
	done
}

# Main entry point
main() {
	require_root
	echo "Starting bootstrap..." | tee -a "$LOGFILE"

	update_packages

	# APT PACKAGES
	local packages=(
		zsh
		tmux
		git
		curl
		wget
        bat
        fzf
        cmake
        make
        g++ 
        pkg-config
        libfontconfig1-dev
        libxcb-xfixes0-dev
        libxkbcommon-dev
        unzip
        fontconfig
	)
	install_packages "${packages[@]}"

	# Clone dotfiles repo to home folder if not present
	DOTFILES_DIR="$HOME/dotfiles"
	if [ ! -d "$DOTFILES_DIR" ]; then
		echo "Cloning dotfiles repo to $DOTFILES_DIR..." | tee -a "$LOGFILE"
		git clone https://github.com/awalvie/dotfiles "$DOTFILES_DIR" | tee -a "$LOGFILE"
	else
		echo "Dotfiles repo already exists at $DOTFILES_DIR." | tee -a "$LOGFILE"
	fi

	echo "Bootstrap completed successfully." | tee -a "$LOGFILE"

    # Symlink zsh config
    if [ -f "$HOME/.zshrc" ]; then
        echo "Backing up existing .zshrc to .zshrc.bak" | tee -a "$LOGFILE"
        mv "$HOME/.zshrc" "$HOME/.zshrc.bak" | tee -a "$LOGFILE"
    fi
    ln -s "$DOTFILES_DIR/unix/zsh/.zshrc" "$HOME/.zshrc" | tee -a "$LOGFILE"

    # Symlink tmux config
    if [ -f "$HOME/.tmux.conf" ]; then
        echo "Backing up existing .tmux.conf to .tmux.conf.bak" | tee -a "$LOGFILE"
        mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak" | tee -a "$LOGFILE"
    fi
    ln -s "$DOTFILES_DIR/unix/tmux/.tmux.conf" "$HOME/.tmux.conf" | tee -a "$LOGFILE"

    # Install and configure keyd (modern key remapping)
    if ! command -v keyd &>/dev/null; then
        echo "Installing keyd from source..." | tee -a "$LOGFILE"
        
        # Clone, build and install keyd
        git clone https://github.com/rvaiya/keyd /tmp/keyd | tee -a "$LOGFILE"
        cd /tmp/keyd
        make && make install | tee -a "$LOGFILE"
        cd - && rm -rf /tmp/keyd
        
        # Enable and start keyd service
        systemctl enable keyd | tee -a "$LOGFILE"
        systemctl start keyd | tee -a "$LOGFILE"
        
        echo "keyd installed successfully." | tee -a "$LOGFILE"
    else
        echo "keyd already installed." | tee -a "$LOGFILE"
    fi
    
    # Symlink keyd configuration
    if [ ! -f "/etc/keyd/default.conf" ]; then
        echo "Setting up keyd configuration..." | tee -a "$LOGFILE"
        mkdir -p /etc/keyd
        ln -s "$DOTFILES_DIR/home/keyd/default.conf" "/etc/keyd/default.conf" | tee -a "$LOGFILE"
        
        # Restart keyd to apply configuration
        systemctl restart keyd | tee -a "$LOGFILE"
        
        echo "keyd configuration symlinked." | tee -a "$LOGFILE"
    else
        echo "keyd configuration already exists." | tee -a "$LOGFILE"
    fi

    # Symlink alacritty config
    if [ -d "$HOME/.config/alacritty" ]; then
        echo "Backing up existing alacritty config to alacritty.bak" | tee -a "$LOGFILE"
        mv "$HOME/.config/alacritty" "$HOME/.config/alacritty.bak" | tee -a "$LOGFILE"
    fi
    ln -s "$DOTFILES_DIR/unix/alacritty" "$HOME/.config/alacritty" | tee -a "$LOGFILE"  

    # Install Alacritty desktop entry and icon from official upstream
    if [ ! -f "/usr/share/applications/Alacritty.desktop" ]; then
        echo "Installing Alacritty desktop entry from upstream..." | tee -a "$LOGFILE"
        curl -fsSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/linux/Alacritty.desktop \
            -o /usr/share/applications/Alacritty.desktop | tee -a "$LOGFILE"
        
        echo "Installing Alacritty icon..." | tee -a "$LOGFILE"
        curl -fsSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/alacritty-term.svg \
            -o /usr/share/pixmaps/Alacritty.svg | tee -a "$LOGFILE"
        
        echo "Updating desktop database..." | tee -a "$LOGFILE"
        update-desktop-database | tee -a "$LOGFILE"
    else
        echo "Alacritty desktop entry already exists." | tee -a "$LOGFILE"
    fi

    # Symlink bin folder
    if [ -d "$HOME/bin" ]; then
        echo "Backing up existing bin directory to bin.bak" | tee -a "$LOGFILE"
        mv "$HOME/bin" "$HOME/bin.bak" | tee -a "$LOGFILE"
    fi
    ln -s "$DOTFILES_DIR/unix/bin" "$HOME/bin" | tee -a "$LOGFILE"

    # Change default shell to zsh for the current user
    sudo chsh -s $(which zsh) $USER 

    # Install starship prompt
    if ! command -v starship &>/dev/null; then
        echo "Installing starship prompt..." | tee -a "$LOGFILE"
        curl -fsSL https://starship.rs/install.sh | bash -s -- -y | tee -a "$LOGFILE"
    else
        echo "starship already installed." | tee -a "$LOGFILE"
    fi

    # Install cargo (Rust) if not present
    if ! command -v cargo &>/dev/null; then
        echo "Installing Rust and Cargo..." | tee -a "$LOGFILE"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y | tee -a "$LOGFILE"
        source "$HOME/.cargo/env"
    else
        echo "Cargo already installed." | tee -a "$LOGFILE"
    fi

    # Ensure cargo is in PATH for subsequent installations
    export PATH="$HOME/.cargo/bin:$PATH"

    # Install bob (Neovim version manager) via cargo
    if ! command -v bob &>/dev/null; then
        echo "Installing bob (Neovim version manager) via cargo..." | tee -a "$LOGFILE"
        cargo install bob-nvim | tee -a "$LOGFILE"
    else
        echo "bob already installed." | tee -a "$LOGFILE"
    fi

    # Install tree-sitter cli if not present
    if ! command -v tree-sitter &>/dev/null; then
        echo "Installing tree-sitter CLI via cargo..." | tee -a "$LOGFILE"
        cargo install tree-sitter-cli | tee -a "$LOGFILE"
    else
        echo "tree-sitter CLI already installed." | tee -a "$LOGFILE"
    fi

    # Install neovim using bob
    if ! command -v nvim &>/dev/null; then
        echo "Installing Neovim using bob..." | tee -a "$LOGFILE"
        bob install stable | tee -a "$LOGFILE"
        bob use stable | tee -a "$LOGFILE"
    else
        echo "Neovim already installed." | tee -a "$LOGFILE"
    fi

    # Install golang if not present
    if ! command -v go &>/dev/null; then
        echo "Installing Go..." | tee -a "$LOGFILE"
        # Get the latest version from Go's API
        GO_VERSION=$(curl -s 'https://go.dev/VERSION?m=text' | head -1)
        wget "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz | tee -a "$LOGFILE"
        tar -C /usr/local -xzf /tmp/go.tar.gz | tee -a "$LOGFILE"
        rm /tmp/go.tar.gz
    else
        echo "Go already installed." | tee -a "$LOGFILE"
    fi

    # Install lazygit if not present
    if ! command -v lazygit &>/dev/null; then
        echo "Installing lazygit..." | tee -a "$LOGFILE"
        go install github.com/jesseduffield/lazygit@latest | tee -a "$LOGFILE"
    else
        echo "lazygit already installed." | tee -a "$LOGFILE"
    fi  

    # Install fnm (Fast Node Manager) if not present
    if ! command -v fnm &>/dev/null; then
        echo "Installing fnm (Fast Node Manager)..." | tee -a "$LOGFILE"
        curl -fsSL https://fnm.vercel.app/install | bash | tee -a "$LOGFILE"
    else
        echo "fnm already installed." | tee -a "$LOGFILE"
    fi

    # Install node using fnm
    if command -v fnm &>/dev/null; then
        echo "Installing latest Node.js using fnm..." | tee -a "$LOGFILE"
        export PATH="$HOME/.fnm:$PATH"
        eval "$(fnm env)"
        fnm install --lts | tee -a "$LOGFILE"
        fnm default lts | tee -a "$LOGFILE"
    fi

    # Install uv
    if ! command -v uv &>/dev/null; then
        echo "Installing uv..." | tee -a "$LOGFILE"
        curl -LsSf https://astral.sh/uv/install.sh | sh | bash | tee -a "$LOGFILE"
    else
        echo "uv already installed." | tee -a "$LOGFILE"
    fi

    # Install IosevkaTerm Nerd Font
    FONT_DIR="/usr/share/fonts/truetype/iosevkaterm-nerd"
    if [ ! -d "$FONT_DIR" ]; then
        echo "Installing IosevkaTerm Nerd Font..." | tee -a "$LOGFILE"
        
        # Create font directory
        mkdir -p "$FONT_DIR" | tee -a "$LOGFILE"
        
        # Download the latest IosevkaTerm Nerd Font release
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IosevkaTerm.zip"
        wget "$FONT_URL" -O /tmp/IosevkaTerm.zip | tee -a "$LOGFILE"
        
        # Extract and install fonts
        unzip -q /tmp/IosevkaTerm.zip -d /tmp/iosevkaterm/ | tee -a "$LOGFILE"
        cp /tmp/iosevkaterm/*.ttf "$FONT_DIR/" | tee -a "$LOGFILE"
        
        # Update font cache
        fc-cache -fv | tee -a "$LOGFILE"
        
        # Cleanup
        rm -rf /tmp/IosevkaTerm.zip /tmp/iosevkaterm/ | tee -a "$LOGFILE"
        
        echo "IosevkaTerm Nerd Font installed successfully." | tee -a "$LOGFILE"
    else
        echo "IosevkaTerm Nerd Font already installed." | tee -a "$LOGFILE"
    fi

    # Make folders for $HOME/code/{origin,lamp,work}
    echo "Creating $HOME/code/{origin,lamp,work} directories..." | tee -a "$LOGFILE"
    mkdir -p $HOME/code/{origin,lamp,work} | tee -a "$LOGFILE"

}

main "$@"

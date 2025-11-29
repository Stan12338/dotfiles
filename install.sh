#!/usr/bin/env bash
set -euo pipefail


repo_packages=(
    "wget"
    "unzip"
    "git"
    "gum"
    "nautilus"
    "nerd-fonts"
    "starship"
    "ghostty"
    "xdg-desktop-portal-hyprland"
    "qt5-wayland"
    "qt6-wayland"
    "firefox"
    "inetutils"
    "vim"
    "fastfetch"
    "fish"
    "jq"
    "brightnessctl"
    "networkmanager"
    "wireplumber"
    "flatpak"
    "ddcutil"
    "qt5-graphicaleffects"
    "qt6-5compat"
    "qt5-imageformats"
    "qt6-imageformats"
    "qt5-multimedia"
    "qt6-multimedia"
    "qt5-svg"
    "qt6-svg"
    "hyprlock"
    "swww"
)

# AUR packages
aur_packages=(
    "hyprland"
    "wf-recorder"
    "grim"
    "slurp"
    "nvim" 
    "ttf-material-symbols-variable-git"
    "quickshell"
    "ttf-font-awesome"
    "ttf-fira-sans"
    "ttf-fira-code"
    "ttf-firacode-nerd"
    "zen-browser-bin"
)


_checkCommandExists() {
    command -v "$1" >/dev/null 2>&1
}

_isPacmanInstalled() {
    pacman -Qi "$1" >/dev/null 2>&1
}

_installYay() {
    echo ":: Installing yay..."
    sudo pacman -S --needed --noconfirm base-devel git
    tmp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
    pushd "$tmp_dir/yay" >/dev/null || exit
    makepkg -si --noconfirm
    popd >/dev/null || exit
    rm -rf "$tmp_dir"
    echo ":: yay installed successfully."
}

_installOhMyZsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo ":: Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo ":: Oh My Zsh already installed."
    fi
}

_installPowerlevel10k() {
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        echo ":: Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    else
        echo ":: Powerlevel10k already installed."
    fi
}

_setDefaultShell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo ":: Setting Zsh as default shell..."
        chsh -s "$(which zsh)"
    else
        echo ":: Zsh is already the default shell."
    fi
}




_installRepoPackages() {
    for pkg in "$@"; do
        if _isPacmanInstalled "$pkg"; then
            echo ":: $pkg is already installed (repo)."
        else
            echo ":: Installing $pkg (repo)..."
            sudo pacman -S --noconfirm --needed "$pkg"
        fi
    done
}

_installAurPackages() {
    for pkg in "$@"; do
        if _checkCommandExists "$pkg"; then
            echo ":: $pkg is already installed (AUR)."
        else
            echo ":: Installing $pkg (AUR)..."
            yay --noconfirm -S "$pkg"
        fi
    done
}

_stowDotfiles() {
    if ! _checkCommandExists "stow"; then
        echo ":: Installing GNU stow..."
        sudo pacman -S --needed --noconfirm stow
    fi

    echo ":: Stowing dotfiles..."
    cd ~/dotfiles
    stow --target="$HOME" . || true
    echo ":: Dotfiles stowed successfully."
}

if _checkCommandExists "yay"; then
    echo ":: yay is already installed."
else
    _installYay
fi

_installRepoPackages "${repo_packages[@]}"
_installAurPackages "${aur_packages[@]}"

_stowDotfiles

if ! _checkCommandExists "zsh"; then
    echo ":: Installing zsh..."
    sudo pacman -S --needed --noconfirm zsh
fi

_installOhMyZsh
_installPowerlevel10k
_setDefaultShell

echo ":: Zsh + Oh My Zsh + Powerlevel10k setup complete!"

echo ":: Setup complete!"

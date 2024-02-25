#!/bin/bash

# Print disclaimer and explanation
echo "Disclaimer: Use this script at your own risk. The author of this script is not responsible for any data loss or damage to configuration files that may occur as a result of running this script. It is recommended to review the script and understand its actions before executing it on your system. By running this script, you acknowledge and accept the risks involved."
echo
echo "This script will set up your Arch Linux system by installing required packages, configuring network settings, downloading dotfiles, setting up wallpapers, and installing Oh My Zsh. Review the script and ensure you understand its actions before proceeding."
echo

# Prompt user to agree to disclaimer
read -r -p "Do you agree to proceed with caution? (y/n): " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Proceeding with setup..."
else
    echo "Exiting script. Please review and ensure you understand the actions before running the script again."
    exit 1
fi

# Function to check if a package is installed
is_installed() {
    pacman -Q "$1" &>/dev/null
}

# Function to install package if not already installed
install_if_needed() {
    if ! is_installed "$1"; then
        echo "Installing $1..."
        sudo pacman -S --noconfirm --needed "$1"
    else
        echo "$1 is already installed."
    fi
}

paru_if_needed() {
    if ! is_installed "$1"; then
        echo "Installing $1..."
        paru -S --noconfirm "$1"
    else
        echo "$1 is already installed."
    fi
}

# Define a function for the restart prompt
restart_i3_prompt() {
    echo "Do you want to restart i3? (Y/n): "
    read -r answer
    if [[ $answer == "" || $answer == "Y" || $answer == "y" ]]; then
        i3-msg restart
    fi
}

# Step 1: Install paru
echo "Installing paru..."
sudo pacman -S --needed base-devel git
if ! is_installed "paru"; then
    git clone https://aur.archlinux.org/paru.git
    cd paru || exit
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
else
    echo "paru is already installed."
fi

# Step 2: Install required packages
echo "Installing required packages..."
install_if_needed "network-manager-applet"
install_if_needed "polybar"
install_if_needed "neovim"
install_if_needed "libnotify"
install_if_needed "feh"
install_if_needed "conky"
install_if_needed "picom"
install_if_needed "github-cli"
install_if_needed "zsh"
install_if_needed "bind"
install_if_needed "ttf-fantasque-sans-mono"
install_if_needed "ttf-cascadia-code"
install_if_needed "ttf-hack-nerd"

# Step 3: Install AUR packages with paru
echo "Installing AUR packages..."
paru_if_needed "termite"
paru_if_needed "protonvpn"
paru_if_needed "trizen"

# Step 4: Start and enable NetworkManager service
echo "Starting and enabling NetworkManager service..."
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager

# Step 5: Get dotfiles
DOTS_DIR="$HOME/dots"
if [ -d "$DOTS_DIR" ]; then
    echo "Dotfiles already exist. Pulling latest changes..."
    cd "$DOTS_DIR" || exit
    git pull origin master
else
    echo "Getting dotfiles..."
    git clone https://github.com/gmarton/dots.git
fi

# Backup existing dotfiles and create symlinks
backup_and_link() {
    local source=$1
    local target=$2

    # Check if target is already a symbolic link
    if [ -L "$target" ]; then
        echo "$target is already a symbolic link. Skipping..."
        return
    fi

    # Check if target directory exists
    if [ -d "$target" ]; then
        mv "$target" "$target-dist"
    fi

    ln -s "$source" "$target"
}

echo "Setting up dotfiles..."
backup_and_link "$DOTS_DIR/.config/i3" "$HOME/.config/i3"
backup_and_link "$DOTS_DIR/.config/polybar" "$HOME/.config/polybar"
backup_and_link "$DOTS_DIR/.config/termite" "$HOME/.config/termite"

# Step 6: Download wallpaper and set it with feh --bg-fill
WALLPAPER_URL="https://w.wallhaven.cc/full/42/wallhaven-42yx2x.jpg"
#WALLPAPER_URL="https://w.wallhaven.cc/full/w8/wallhaven-w82ez6.png"
WALLPAPER_DIR="$DOTS_DIR/bg"
mkdir -p "$WALLPAPER_DIR"
echo "Downloading wallpaper..."
curl -o "$WALLPAPER_DIR/wallpaper.jpg" "$WALLPAPER_URL"
echo "Applying wallpaper..."
feh --bg-fill "$WALLPAPER_DIR/wallpaper.jpg"

# Step 7: Get Arco scripts
cd $HOME
git clone https://github.com/arcolinuxd/arco-i3.git

# Step 9: Install fonts with Erik's script
arco-i3/700-installing-fonts.sh

echo "Setup complete!"
restart_i3_prompt

# Step 8: Install Oh My Zsh if not already installed
echo "Checking if Oh My Zsh is installed..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is not installed. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed."
fi


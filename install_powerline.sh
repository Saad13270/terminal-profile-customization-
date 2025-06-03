#!/bin/bash
set -euxo pipefail

# Step 1: Install dependencies
sudo apt update
sudo apt install -y python3-pip pipx fonts-powerline unzip curl

# Step 2: Ensure pipx path is set
pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"

# Step 3: Install powerline-status
pipx install powerline-status || echo "powerline-status already installed."

# Step 4: Add Powerline Vim support
POWERLINE_VIM_PATH="$HOME/.local/pipx/venvs/powerline-status/lib/python3.12/site-packages/powerline/bindings/vim"
if ! grep -q "$POWERLINE_VIM_PATH" "$HOME/.vimrc" 2>/dev/null; then
    echo "set rtp+=$POWERLINE_VIM_PATH" >> "$HOME/.vimrc"
fi

# Step 5: Append additional Vim settings if available
if [ -f configs/.vimrc ]; then
    cat configs/.vimrc >> "$HOME/.vimrc"
fi

# Step 6: Automatically install Hack Nerd Font
mkdir -p ~/.fonts
mkdir -p /tmp/nerd-fonts
cd /tmp/nerd-fonts
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
unzip Hack.zip -d ~/.fonts/
fc-cache -vf ~/.fonts/

# Step 7: Enable Powerline in Bash prompt
BASH_BINDING="$HOME/.local/pipx/venvs/powerline-status/lib/python3.12/site-packages/powerline/bindings/bash/powerline.sh"
if ! grep -q "$BASH_BINDING" "$HOME/.bashrc"; then
    {
        echo ''
        echo '# Enable Powerline for Bash'
        echo 'if [ -x "$HOME/.local/bin/powerline-daemon" ]; then'
        echo '    powerline-daemon -q'
        echo "    source \"$BASH_BINDING\""
        echo 'fi'
    } >> "$HOME/.bashrc"
fi

# Step 8: Cleanup temp files and notify user
rm -rf /tmp/nerd-fonts
echo "✅ Powerline setup complete. Please restart your terminal or run: source ~/.bashrc"

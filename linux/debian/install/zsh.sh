#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"

needs_restart=false

echo "***** Setting up zsh *****"

#zsh install
zsh_file="/usr/bin/zsh"
if [ ! -f "$zsh_file" ] ; then
    echo "Installing zsh..."
    packages="zsh"
    echo "$packages" | xargs sudo apt-get -y install
    needs_restart=true
fi

# oh-my-zsh install
omz_dir="$HOME/.oh-my-zsh"
if [ ! -d "$omz_dir" ] ; then
    echo "Installing oh-my-zsh..."
    sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
    needs_restart=true
fi

# set default shell to zsh
if [ "$zsh_file" != "$SHELL" ] ; then
    echo "Setting default shell to zsh..."
    chsh -s $(which zsh)
    needs_restart=true
fi

# install powerlevel10k
p10k_dir="$omz_dir/custom/themes/powerlevel10k"
if [ ! -d "$p10k_dir" ] ; then 
    echo " Installing powerlevel10k..."
    git clone https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    needs_restart=true
fi

# set powerlevel10k as the ZSH_THEME
if ! grep 'ZSH_THEME="powerlevel10k\/powerlevel10k"' "$HOME/.zshrc" &> /dev/null ; then
    echo "Setting default theme to powerlevel10k..."
    sed -i 's/ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' "$HOME/.zshrc"
    needs_restart=true
fi

# add custom zsh profile
zsh_profile="$git_dir/linux/debian/zsh_profile.sh"
if ! grep "source \"$zsh_profile\"" "$HOME/.zshrc" &> /dev/null ; then
    echo "Installing custom zsh options..."
    echo "source \"$zsh_profile\"" >> "$HOME/.zshrc"
    needs_restart=true
fi

echo "***** Done setting up zsh *****"

if [ "$needs_restart" = true ]; then
    echo "***** NOTE: Restart terminal when install is completely finished for zsh *****"
fi

#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"

echo "***** Installing zsh... *****"
packages="zsh"
echo "$packages" | xargs sudo apt-get -y install
sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
chsh -s $(which zsh)
echo "source \"$git_dir/linux/debian/zsh_profile.sh\"" >> "$HOME/.zshrc"
echo "***** Done installing zsh. *****"
echo "***** NOTE: Restart terminal when install is completely finished for zsh. *****"

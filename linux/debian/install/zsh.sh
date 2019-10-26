#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"

echo "***** Installing zsh... *****"
packages="zsh"
echo "$packages" | xargs sudo apt-get -y install
sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
chsh -s $(which zsh)
echo "***** Done installing zsh. *****"

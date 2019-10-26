#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"

echo "***** Installing vim... *****"
packages="vim"
echo "$packages" | xargs sudo apt-get -y install
echo "***** Done installing vim. *****"

echo "***** Installing vim profile... *****"
vim_profile="$git_dir/vim/profile.vim"
vimrc="$HOME/.vimrc"
echo "so $vim_profile" > $vimrc
echo "***** Done installing vim profile... *****"

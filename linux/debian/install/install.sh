#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"
echo "***** Updating... *****"
sudo apt-get update
echo "***** Done updating. *****"

echo "***** Installing packages for git... *****"
cat git.list | xargs sudo apt-get -y install
echo "***** Done installing packages for git. *****"

echo "***** Installing git preferences... *****"
source git.sh
echo "***** Done installing git preferences. *****"

echo "***** Installing packages for vim... *****"
cat vim.list | xargs sudo apt-get -y install
echo "***** Done installing packages for vim. *****"

echo "***** Installing vim profile... *****"
vim_profile="$git_dir/vim/profile.vim" 
vimrc="$HOME/.vimrc"
echo "so $vim_profile" > $vimrc
echo "***** Done installing vim profile. *****"

echo "***** Installing profiles to ~/.bashrc *****"
prepend_profile="$git_dir/linux/debian/bash/prepend_profile.sh"
append_profile="$git_dir/linux/debian/bash/append_profile.sh"
bashrc="$HOME/.bashrc"
printf '%s\n%s\n\n%s\n' "#User prepend profile" "source $prepend_profile" "$(cat $bashrc)" > $bashrc
echo "" >> $bashrc
echo "#User append profile" >> $bashrc
echo "source $append_profile" >> $bashrc
echo "***** Done installing profile to ~/.bashrc *****"

#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"
echo "***** Updating... *****"
sudo apt-get update
echo "***** Done updating. *****"

source git.sh
source vim.sh
source zsh.sh

#echo "***** Installing profiles to ~/.bashrc *****"
#prepend_profile="$git_dir/linux/debian/bash/prepend_profile.sh"
#append_profile="$git_dir/linux/debian/bash/append_profile.sh"
#bashrc="$HOME/.bashrc"
#printf '%s\n%s\n\n%s\n' "#User prepend profile" "source $prepend_profile" "$(cat $bashrc)" > $bashrc
#echo "" >> $bashrc
#echo "#User append profile" >> $bashrc
#echo "source $append_profile" >> $bashrc
#echo "***** Done installing profile to ~/.bashrc *****"

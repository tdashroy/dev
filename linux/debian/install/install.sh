#!/bin/sh
echo "***** Updating... *****"
sudo apt-get update
echo "***** Done updating. *****"

echo "***** Installing packages required for git... *****"
cat git.list | xargs sudo apt-get -y install
echo "***** Done installing packaages required for git. *****"

echo "***** Installing git preferences... *****"
source git.sh
echo "***** Done installing git preferences. *****"

echo "***** Installing profiles to ~/.bashrc *****"
prepend_profile="$(cd "$(dirname "$PWD")"; pwd)/bash/prepend_profile.sh"
append_profile="$(cd "$(dirname "$PWD")"; pwd)/bash/append_profile.sh"
bashrc="$(cd "$HOME"; pwd)/.bashrc"
printf '%s\n%s\n\n%s\n' "#User prepend profile" "source $prepend_profile" "$(cat $bashrc)" > $bashrc
echo "" >> $bashrc
echo "#User append profile" >> $bashrc
echo "source $append_profile" >> $bashrc
echo "***** Done installing profile to ~/.bashrc *****"

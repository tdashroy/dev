#!/bin/sh
echo "***** Updating... *****"
sudo apt-get update
echo "***** Done updating. *****"

echo "***** Installing packages required for git... *****"
cat git.list | xargs sudo apt-get -y install
echo "***** Done installing packaages required for git. *****"

echo "***** Installing profile to ~/.bashrc *****"
bash_profile="$(cd "$(dirname "$PWD")"; pwd)/bash/profile.sh"
bashrc="$(cd "$HOME"; pwd)/.bashrc"
echo "" >> $bashrc
echo "#User profile" >> $bashrc
echo "source $bash_profile" >> $bashrc
echo "***** Done installing profile to ~/.bashrc *****"

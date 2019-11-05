#!/bin/bash

packages="git"
echo "$packages" | xargs sudo apt-get -y install

# set git to convert CRLF line endings to LF on commit
git config --global core.autocrlf input

# prompt for user name and email
while true; do
    read -p 'Would you like to set your git name and email? [y/n]' reply
    case $reply in
        [Yy]* ) git_user=true; break;;
        [Nn]* ) git_user=false; break;;
    esac
done

if [ "$git_user" = true ] ; then
    read -p 'Name: ' user_name
    read -p 'Email: ' user_email

    git config --global user.name "$user_name"
    git config --global user.email "$user_email"
fi

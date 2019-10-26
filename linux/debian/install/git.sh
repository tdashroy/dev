#!/bin/sh
packages="git bash-completion"
echo "$packages" | xargs sudo apt-get -y install

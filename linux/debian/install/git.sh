#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"
source "$git_dir/linux/debian/install/common.sh"
source "$git_dir/linux/debian/install/args.sh"

packages="git"
echo "$packages" | xargs sudo apt-get -y install

# set git to convert CRLF line endings to LF on commit
set_option $overwrite $prompt $user_input 'git autocrlf' 'git config --global --get core.autocrlf' 'git config --global core.autocrlf input' 'input'

# set user name
set_option $overwrite $prompt $user_input 'git user name' 'git config --global --get user.name' 'git config --global user.name "${new_val}"'

# set user email
set_option $overwrite $prompt $user_input 'git user email' 'git config --global --get user.email' 'git config --global user.email "${new_val}"'

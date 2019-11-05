#!/bin/zsh
git_dir="$( cd "$( dirname "${(%):-%x}" )/../../" >/dev/null 2>&1 && pwd )"

# set up ls colors to look better with the OneHalfDark theme
eval $( dircolors "$git_dir/linux/debian/.dircolors" )

# make the default user the current user, removing the username and computer name from the prompt
export DEFAULT_USER="$USER"

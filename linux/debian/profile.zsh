#!/bin/zsh
git_dir="$( cd "$( dirname "${(%):-%x}" )/../../" >/dev/null 2>&1 && pwd )"

# set up ls colors to look better with the OneHalfDark theme
eval "$(dircolors "$git_dir/linux/debian/dircolors")"
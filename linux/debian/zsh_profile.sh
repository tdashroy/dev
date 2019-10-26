#!/bin/zsh
git_dir="$( cd "$( dirname "${(%):-%x}" )/../../" >/dev/null 2>&1 && pwd )"
eval $( dircolors "$git_dir/linux/debian/.dircolors" )

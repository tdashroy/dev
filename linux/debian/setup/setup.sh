#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"
source "$git_dir/linux/debian/setup/common.sh"
source "$git_dir/linux/debian/setup/args.sh"

source "$git_dir/linux/debian/setup/git.sh"
#source "$git_dir/linux/debian/setup/vim.sh"
source "$git_dir/linux/debian/setup/zsh.sh"

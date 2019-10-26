#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"
echo "***** Updating... *****"
sudo apt-get update
echo "***** Done updating. *****"

source git.sh
source vim.sh
source zsh.sh

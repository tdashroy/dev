#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"

# commented out b/c it makes it impossible to work with windows apps
#echo "***** Setting up WSL mount options... *****"
#wsl_conf="$git_dir/linux/debian/install/wsl.conf"
#cat "$wsl_conf" | sudo tee "/etc/wsl.conf" >/dev/null
#echo "***** Done setting up WSL mount options. *****"

echo "***** Setting up WSL git to use windows credential manager... *****"
# todo: make this find the credential-helper instead
git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"
echo "***** Done setting up WSL git to use windows credential manager. *****"

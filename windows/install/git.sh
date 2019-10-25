#!/bin/sh
echo "***** Setting up WSL git to use windows credential manager... *****"
git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"
echo "***** Done setting up WSL git to use windows credential manager. *****"

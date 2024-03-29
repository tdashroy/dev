#!/bin/zsh
git_dir="$( cd "$( dirname "${(%):-%x}" )/../../" >/dev/null 2>&1 && pwd )"

# turn off terminal beep
unsetopt beep

# set up ls colors to look better with the OneHalfDark theme
eval "$(dircolors "$git_dir/linux/debian/dircolors")"

# make tab completion colors the same as dircolors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# increase history size from omz defaults
HISTSIZE=10000000
SAVEHIST=5000000

[ -d "$HOME/.local/bin" ] && export path=("$HOME/.local/bin" $path)
[ -d "$HOME/bin" ] && export path=("$HOME/bin" $path)

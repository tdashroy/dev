#!/bin/sh
this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ -t 1 ]; then
	exec zsh
fi

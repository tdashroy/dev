#!/bin/bash

overwrite=false
prompt=false
user_input='new'

while [[ $# -gt 0 ]] ; do
    case "$1" in
        -o|--overwrite) 
            overwrite=true; 
            shift
            ;;

        -p|--prompt) 
            prompt=true; 
            shift
            ;;

        -u)
            shift
            user_input="$1"
            case $user_input in
                none) shift;;
                new) shift;;
                overwrite) shift;;
                *) echo "bad argument for -u option: $user_input. Should be one of: none, new, or overwrite." >&2; exit 1;;
            esac
            ;;
        --user_input=*) 
            user_input="${1#*=}";
            case $user_input in
                none) shift;;
                new) shift;;
                overwrite) shift;;
                *) echo "bad argument for --user_input option: $user_input. Should be one of: none, new, or overwrite." >&2; exit 1;;
            esac
            ;;
        --user_input) echo "--user-input requires an argument. Should be one of: none, new, or overwrite." >&2; exit 1;;

        -*) echo "unknown option: $1" >&2; exit 1;;
        *) echo "bad argument: $1" >&2; exit 1;;
    esac
done

packages="git"
echo "$packages" | xargs sudo apt-get -y install

set_option() {
    local overwrite=$1
    local prompt=$2
    local user_input=$3
    local option=$4
    local get_cmd=$5
    local set_cmd=$6
    local new_val=$7

    if [[ -z "$new_val" && "$user_input" = 'none' ]] ; then
        false; return
    fi

    local cur_val="$(eval "$get_cmd")"
    local set_prompt="$( [[ -n "$new_val" ]] && echo " to $new_val" )"
    if [[ -z "$cur_val" ]] ; then
        set_prompt="Would you like to set ${option}${set_prompt}?"
    else
        if [[ "$cur_val" = "$new_val" ]] ; then
            true; return
        fi

        if [[ "$overwrite" = false || ( -z "$new_val" && "$user_input" != 'overwrite' ) ]] ; then
            false; return
        fi
	
        set_prompt="Would you like to overwrite $option from ${cur_val}${set_prompt}?"
    fi
    
    if [[ "$prompt" = true ]] ; then
        while true; do
            read -p "$set_prompt [y/n] " reply
            case $reply in
                [Yy]* ) break;;
                [Nn]* ) false; return; break;;
            esac
        done
    fi

    if [[ -z "$new_val" ]] ; then
        read -p "Please enter value for ${option}: " new_val
    fi

    echo "Setting $option to ${new_val}..."
    eval "$set_cmd"

    cur_val="$(eval "$get_cmd")"
    if [[ "$cur_val" != "$new_val" ]] ; then
        echo "Failed to set $option to ${new_val}."
        false; return
    fi

    true; return
}

# set git to convert CRLF line endings to LF on commit
set_option $overwrite $prompt $user_input 'git autocrlf' 'git config --global --get core.autocrlf' 'git config --global core.autocrlf input' 'input'

# set user name
set_option $overwrite $prompt $user_input 'git user name' 'git config --global --get user.name' 'git config --global user.name "${new_val}"'

# set user email
set_option $overwrite $prompt $user_input 'git user email' 'git config --global --get user.email' 'git config --global user.email "${new_val}"'
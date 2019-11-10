#!/bin/bash

# functions
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
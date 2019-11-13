#!/bin/bash

# functions
run_install_task() {
    local ask=$1
    local overwrite=$2
    local user_input=$3
    local user_input_required=$4
    local install_string=$5
    local overwrite_string=$6
    local exists_cmd=$7
    local install_cmd=$8

    if [[ "$user_input_required" = true && "$user_input" = 'skip' ]] ; then
        false; return
    fi

    local task_string="$install_string"
    if eval "$exists_cmd" &> /dev/null ; then
        if [[ "$overwrite" = false || ("$user_input_required" = true && "$user_input" != 'overwrite') ]] ; then
            false; return
        fi
        task_string="$overwrite_string"
    fi

    if [[ "$ask" = true ]] ; then
        while true; do
            read -p "Would you like to ${task_string}? [y/n] " reply
            case $reply in
                [Yy]* ) break;;
                [Nn]* ) false; return; break;;
            esac
        done
    fi

    echo "Running task to ${task_string}..."
    if ! eval "$install_cmd" ; then
        echo "Failed to ${task_string}."
        false; return
    fi

    true; return
}
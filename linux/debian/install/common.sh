#!/bin/bash

### variables ###

is_wsl="$( { uname -r ; cat /proc/version ; cat /proc/sys/kernel/osrelease ; } | grep 'Microsoft' &> /dev/null ; echo "$?")"


### functions ###

# generic function for running install tasks based on the parameters provided.
# the first 4 parameters configure how the install task will be run.
#   ask - whether or not to prompt the user before running the install_cmd. possible values are...
#       always - always prompt the user before running install_cmd
#       overwrite - only prompt the user if exists_cmd is true
#       <any other value> - don't prompt the user
#   overwrite - if exists_cmd returns true, whether or not to run the install_cmd
#   user_input - only relevant if user_input_required is true. possible values are...
#       all - still run install_cmd if exists_cmd returns true
#       none - return false if user input is required
#       <any other value> - only run install_cmd if exists_cmd is false
#   user_input_required - true if either exists_cmd or install_cmd requires user input
# 
# the next 2 parameters are strings describing the task to be run. they will also be used in the user prompts if required.
#   install_string - string describing normal install. 
#   overwrite_string - string describing overwrite install. this might be different from install_string, 
#                      for example, if you want to show the value being overwritten.
#
# the final 2 parameters are commands that are run with the eval command.
#   exists_cmd - command to run to tell whether or not what is being installed is already installed. 
#                a successful return code will affect the outcome of the function based on the options above
#   install_cmd - command to run to perform the install for this task
run_install_task() {
    local ask=$1
    local overwrite=$2
    local user_input=$3
    local user_input_required=$4
    local install_string=$5
    local overwrite_string=$6
    local exists_cmd=$7
    local install_cmd=$8

    if [[ "$user_input_required" = true && "$user_input" = 'none' ]] ; then
        false; return
    fi

    local task_string="$install_string"
    local exists=false
    if eval "$exists_cmd" ; then
        if [[ "$overwrite" != true || ("$user_input_required" = true && "$user_input" != 'all') ]] ; then
            false; return
        fi
        task_string="$overwrite_string"
        exists=true
    fi

    if [[ "$ask" = 'all' || ( "$exists" = true && "$ask" = 'overwrite' ) ]] ; then
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

# stolen from https://stackoverflow.com/a/17841619/500167
# this works in shell commands, but for some reason isn't working fully in scripts...
join_by() { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
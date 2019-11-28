#!/bin/bash

if $common_first_run ; then

    ### variables ###

    # variable telling whether or not the version of linux being used is a Windows Subystem for Linux
    if { uname -r ; cat /proc/version ; cat /proc/sys/kernel/osrelease ; } | grep 'Microsoft' &> /dev/null ; then
        is_wsl=true
    else
        is_wsl=false
    fi

    ### functions ###

    # generic function for running install tasks based on the parameters provided.
    # the first 4 parameters configure how the install task will be run.
    #   ask - whether or not to prompt the user before running the install_cmd. possible values are...
    #       always - always prompt the user before running install_cmd
    #       overwrite - only prompt the user if exists_cmd is true
    #       <any other value> - don't prompt the user
    #   overwrite - if exists_cmd returns true, whether or not to run the install_cmd
    #   input - only relevant if input_required is true. possible values are...
    #       all - still run install_cmd if exists_cmd returns true
    #       none - return false if user input is required
    #       <any other value> - only run install_cmd if exists_cmd is false
    #   input_required - true if either exists_cmd or install_cmd requires user input
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
    #
    # returns
    #   0 - successful install
    #   1 - attempted install that failed
    #   2 - no attempted install
    run_install_task() {
        local ask="$1"
        local overwrite="$2"
        local input="$3"
        local input_required="$4"
        local install_string="$5"
        local overwrite_string="$6"
        local exists_cmd="$7"
        local install_cmd="$8"

        if [[ "$input_required" == true && "$input" = 'none' ]] ; then
            return 2
        fi

        local task_string="$install_string"
        local exists=false
        if eval "$exists_cmd" ; then
            if [[ "$overwrite" != true || ("$input_required" = true && "$input" != 'all') ]] ; then
                return 2
            fi
            task_string="$overwrite_string"
            exists=true
        fi

        if [[ "$ask" == 'always' || ( "$exists" == true && "$ask" == 'overwrite' ) ]] ; then
            while true; do
                read -p "Would you like to ${task_string}? [y/n] " reply
                case $reply in
                    [Yy]* ) break;;
                    [Nn]* ) if [[ "$exists" == true ]] ; then return 2 ; else return 1 ; break;;
                esac
            done
        fi

        echo "Running task to ${task_string}..."
        if ! eval "$install_cmd" ; then
            echo "Failed to ${task_string}."
            return 1
        fi

        return 0
    }

    run_uninstall_task() {
        local ask="$1"
        local uninstall_string="$2"
        local exists_cmd="$3"
        local uninstall_cmd="$4"

        if ! eval "$exists_cmd" ; then
            return 2
        fi

        if [[ "$ask" == 'always' || "$ask" = 'overwrite' ]] ; then
            while true; do
                read -p "Would you like to ${uninstall_string}? [y/n] " reply
                case $reply in
                    [Yy]* ) break;;
                    [Nn]* ) return 2; break;;
                esac
            done
        fi

        echo "Running task to ${uninstall_string}..."
        if ! eval "$uninstall_cmd" ; then
            echo "Failed to ${uninstall_string}."
            return 1
        fi

        return 0
    }

    # returns
    #   0 - success
    #   1 - fail
    #   2 - no action
    run_setup_task() {
        local setup_type="${1}"
        local restore_file=""
        local ask="${2}"
        local overwrite="${3}"
        local input="${4}"
        local input_required="${5}"
        local install_string="${6}"
        local overwrite_string="${7}"
        local uninstall_string="${8}"
        local exists_cmd="${9}"
        local install_cmd="${10}"
        local uninstall_cmd="${11}"

        if [[ "$setup_type" == 'install' ]] ; then
            run_install_task "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$exists_cmd" "$install_cmd"
            return $?
        elif [[ "$setup_type" == 'uninstall' ]] ; then
            run_uninstall_task "$ask" "$uninstall_string" "$exists_cmd" "$uninstall_cmd"
            return $?
        else
            return 1
        fi
    }

    # stolen from https://stackoverflow.com/a/17841619/500167
    # this works in shell commands, but for some reason isn't working fully in scripts...
    join_by() { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

    common_first_run=false

fi
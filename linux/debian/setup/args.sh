#!/bin/bash

if $args_first_run ; then
    
    # adapted from: https://stackoverflow.com/a/55008165/500167
    # preprocess options to:
    # - expand -xyz into -x -y -z
    # - expand -shortopt=arg into -shortopt arg
    # - expand --longopt=arg into --longopt arg
    args=()
    end_of_opt=
    while [[ $# -gt 0 ]] ; do
        arg="$1"; shift
        case "${end_of_opt}${arg}" in
            --) args+=("$arg"); end_of_opt=1 ;;
            --*=*) args+=("${arg%%=*}" "${arg#*=}") ;;
            --*) args+=("$arg") ;;
            -*=*) args+=("${arg%%=*}" "${arg#*=}") ;;
            -*) for i in $(seq 2 ${#arg}); do args+=("-${arg:i-1:1}"); done ;;
            *) args+=("$arg") ;;
        esac
    done

    # set preprocessed args back as the script args
    set -- "${args[@]}"

    # parse command line args
    args=()
    end_of_opt=
    while [[ $# -gt 0 ]] ; do
        arg="$1"; shift
        case "${end_of_opt}${arg}" in
            --) args+=("$arg"); end_of_opt=1 ;;
            -a|--ask) g_ask=$1
                case "$g_ask" in
                    always) shift ;;
                    never) shift ;;
                    overwrite) shift ;;
                    *) echo "bad argument for -a|--ask option: $g_ask. Should be one of: always, never, or overwrite." >&2 ; exit 1 ;;
                esac
                ;;
            -f|--restore-file) g_restore_file="$1" ;;
            -i|--input) g_input="$1"
                case $g_input in
                    all) shift ;;
                    new) shift ;;
                    none) shift ;;
                    *) echo "bad argument for -u|--input option: $g_input. Should be one of: all, new, or none." >&2 ; exit 1 ;;
                esac
                ;;
            -o|--overwrite) g_overwrite=true ;;
            -u|--uninstall) g_setup_type='uninstall' ;;
            -v|--verbose) g_verbose=true ;;

            *) args+=("$arg") ;;
        esac
    done

    # set leftover args back as script args
    set -- "${args[@]}"

    # defaults for anything not set
    [[ -z "$g_ask" ]] && g_ask='overwrite'
    [[ -z "$g_input" ]] && g_input='new'
    [[ -z "$g_overwrite" ]] && g_overwrite=false
    [[ -z "$g_setup_type" ]] && g_setup_type='install'
    [[ -z "$g_verbose" ]] && g_verbose=false

    # if [[ "$g_setup_type" == 'uninstall' && ! -f "$g_restore_file" ]] ; then
    #     while true; do
    #         echo "Could not find restore file ${g_restore_file}."
    #         read -p "Would you like to continue with default uninstall? [y/n] " reply
    #         case $reply in
    #             [Yy]* ) break;;
    #             [Nn]* ) exit 1; break;;
    #         esac
    #     done
    # fi

    args_first_run=false
fi

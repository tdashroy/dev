#!/bin/bash

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

set -- "${args[@]}"

# parse default options
args=()
end_of_opt=
while [[ $# -gt 0 ]] ; do
    arg="$1"; shift
    case "${end_of_opt}${arg}" in
        --) args+=("$arg"); end_of_opt=1 ;;
        -a|--ask) g_ask=true ;;
        -o|--overwrite) g_overwrite=true ;;
        -u|--user_input) g_user_input="$1"
            case $g_user_input in
                new) shift ;;
                overwrite) shift ;;
                skip) shift ;;
                *) echo "bad argument for -u|--user_input option: $g_user_input. Should be one of: new, overwrite, or skip." >&2; exit 1;;
            esac
            ;;
        -v|--verbose) g_verbose=true ;;

        *) args+=("$arg") ;;
    esac
done

set -- "${args[@]}"

# defaults
[[ -z "$g_ask" ]] && g_ask=false
[[ -z "$g_overwrite" ]] && g_overwrite=false
[[ -z "$g_user_input" ]] && g_user_input='new'
[[ -z "$g_verbose" ]] && g_verbose='new'
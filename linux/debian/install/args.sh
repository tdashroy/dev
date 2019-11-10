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

# parse options
args=()
end_of_opt=
while [[ $# -gt 0 ]] ; do
    arg="$1"; shift
    case "${end_of_opt}${arg}" in
        --) args+=("$arg"); end_of_opt=1 ;;
        -o|--overwrite) overwrite=true ;;
        -p|--prompt) prompt=true ;;
        -u|--user_input) user_input="$1"
            case $user_input in
                none) shift ;;
                new) shift ;;
                overwrite) shift ;;
                *) echo "bad argument for -u|--user_input option: $user_input. Should be one of: none, new, or overwrite." >&2; exit 1;;
            esac
            ;;

        *) args+=("$arg") ;;
    esac
done

set -- "${args[@]}"

# defaults
[[ -z "$overwrite" ]] && overwrite=false
[[ -z "$prompt" ]] && prompt=false
[[ -z "$user_input" ]] && user_input='new'
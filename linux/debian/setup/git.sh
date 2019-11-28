#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"
source "$git_dir/linux/debian/setup/common.sh"
source "$git_dir/linux/debian/setup/args.sh"

# install packages needed for git
git_install() {
    local packages="git"

    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite=false
    local input="$g_input"
    local input_required=false
    local install_string='install git'
    local overwrite_string=
    local uninstall_string='uninstall git'
    exists_cmd() { which git &> /dev/null; }
    install_cmd() { echo "$packages" | xargs sudo apt-get -y install; }
    uninstall_cmd() { echo "$packages" | xargs sudo apt-get --auto-remove -y purge; }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd

    return $ret
}

# set git to convert CRLF line endings to LF on commit
git_autocrlf() {
    local autocrlf="$(git config --global --get core.autocrlf)"

    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite="$g_overwrite"
    local input="$g_input"
    local input_required=false
    local install_string='set git autocrlf to input'
    local overwrite_string="overwrite git autocrlf from $autocrlf to input"
    local uninstall_string="unset git autocrlf from input"
    # todo: maybe split exists_cmd into two commands: one for install and one for uninstall. 
    #       this way for install we can just check to see if we're overwriting, but for uninstall 
    #       we can check to see if the specific command was set.
    #       will probably end up with something similar/better than this once restore functionality 
    #       is addded, so gonna postpone for now
    exists_cmd() { [[ -n "$autocrlf" ]]; }
    install_cmd() { git config --global core.autocrlf input; }
    uninstall_cmd() { git config --global --unset-all core.autocrlf input; }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd

    return $ret
}

# set git user name
git_user_name() {
    local user_name="$(git config --global --get user.name)"

    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite="$g_overwrite"
    local input="$g_input"
    local input_required=true
    local install_string='set git user name'
    local overwrite_string="overwrite git user name from $user_name"
    local uninstall_string="unset git user name from $user_name"
    exists_cmd() { [[ -n "$user_name" ]]; }
    install_cmd() { 
        read -p "Please enter your git user name: " reply
        git config --global user.name "$reply"
    }
    uninstall_cmd() { git config --global --unset-all user.name; }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd

    return $ret
}

# set git user email
git_user_email() {
    local user_email="$(git config --global --get user.email)"

    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite="$g_overwrite"
    local input="$g_input"
    local input_required=true
    local install_string='set git user email'
    local overwrite_string="overwrite git user email from $user_email"
    local uninstall_string="unset git user email from $user_email"
    exists_cmd() { [[ -n "$user_email" ]]; }
    install_cmd() { 
        read -p "Please enter your git user email: " reply
        git config --global user.email "$reply"
    }
    uninstall_cmd() { git config --global --unset-all user.email; }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd

    return $ret

}

# setup wsl to use the Windows Credential Manager
# todo: make this find the credential-helper instead
git_credential_helper() {
    if [[ -v is_wsl ]] && ! $is_wsl ; then
        return 1
    fi

    local cur_cred_helper="$(git config --global --get credential.helper)"
    local tgt_cred_helper="/mnt/c/Program\\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"

    local ask="$g_ask"
    local setup_type="$g_setup_type"
    local overwrite="$g_overwrite"
    local input="$g_input"
    local input_required=false
    local install_string='set git credential helper to use Windows Credential Manager'
    local overwrite_string="overwrite git credential helper from $cur_cred_helper to $tgt_cred_helper"
    local uninstall_string='unset git credential helper from using Windows Credential Manager'
    exists_cmd() { [[ -n "$cur_cred_helper" ]]; }
    install_cmd() { git config --global credential.helper "$tgt_cred_helper"; }
    uninstall_cmd() { git config --global --unset-all credential.helper "$tgt_cred_helper"; }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'

    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd

    return $ret
}

# returns
#   0 - all success
#   1 - at least one failure
install() {
    local last=
    local ret=

    git_install
    last=$?
    ret=$( if [[ $ret != 1]]; then ret=$last; fi )
    
    if [[ $last == 1 ]] ; then
        echo "Couldn't install git, skipping the rest of the git configuration."
        return 1
    fi 

    git_autocrlf
    last=$?
    ret=$( if [[ $ret != 1]]; then ret=$last; fi )

    git_user_name
    last=$?
    ret=$( if [[ $ret != 1]]; then ret=$last; fi )

    git_user_email
    last=$?
    ret=$( if [[ $ret != 1]]; then ret=$last; fi )

    git_credential_helper
    last=$?
    ret=$( if [[ $ret != 1]]; then ret=$last; fi )
    
    if [[ $ret != 1 ]] ; then
        ret=0
    fi
    return $ret
}

# returns
#   0 - all success
#   1 - at least one failure
uninstall() {
    local last=
    local ret=
    
    git_credential_helper
    last=$?
    ret=$( if [[ $ret != 1]]; then ret=$last; fi )
    
    git_user_email
    last=$?
    ret=$( if [[ $ret != 1]]; then ret=$last; fi )
    
    git_user_name
    last=$?
    ret=$( if [[ $ret != 1]]; then ret=$last; fi )
    
    git_autocrlf
    last=$?
    ret=$( if [[ $ret != 1]]; then ret=$last; fi )
    
    git_install
    last=$?
    ret=$( if [[ $ret != 1]]; then ret=$last; fi )
    
    if [[ $ret != 1 ]] ; then
        ret=0
    fi
    return $ret
}

eval "$g_setup_type"
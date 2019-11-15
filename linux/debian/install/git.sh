#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"
source "$git_dir/linux/debian/install/common.sh"
source "$git_dir/linux/debian/install/args.sh"

install() {
    # install packages needed for git
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string='install git'
    overwrite_string=''
    exists_cmd() { which git &> /dev/null; }
    install_cmd() { 
        packages="git"
        echo "$packages" | xargs sudo apt-get -y install
    }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'

    if ! exists_cmd ; then
        echo "Couldn't install git, skipping the rest of the git configuration."
        return
    fi 
    
    # set git to convert CRLF line endings to LF on commit
    autocrlf="$(git config --global --get core.autocrlf)"
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string='set git autocrlf to input'
    overwrite_string="overwrite git autocrlf from $autocrlf to input"
    exists_cmd() { [[ "$autocrlf" = 'input' ]]; }
    install_cmd() { git config --global core.autocrlf input; }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'

    # set user name
    user_name="$(git config --global --get user.name)"
    ask="$g_ask"
    overwrite="$g_overwrite"
    user_input="$g_user_input"
    user_input_required=true
    install_string='set git user name'
    overwrite_string="overwrite git user name from $user_name"
    exists_cmd() { [[ -n "$user_name" ]]; }
    install_cmd() { 
        read -p "Please enter your git user name: " reply
        git config --global user.name "$reply"
    }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'

    # set user email
    user_email="$(git config --global --get user.email)"
    ask="$g_ask"
    overwrite="$g_overwrite"
    user_input="$g_user_input"
    user_input_required=true
    install_string='set git user email'
    overwrite_string="overwrite git user email from $user_email"
    exists_cmd() { [[ -n "$user_email" ]]; }
    install_cmd() { 
        read -p "Please enter your git user email: " reply
        git config --global user.email "$reply"
    }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'

    if [[ "$is_wsl" != true ]] ; then
        return
    fi

    # setup wsl to use Windows Credential Manager
    # todo: make this find the credential-helper instead
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string='set git user name'
    overwrite_string=
    exists_cmd() { git config --global --get credential.helper &> /dev/null; }
    install_cmd() { git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"; }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'
}

install
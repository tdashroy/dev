#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"
source "$git_dir/linux/debian/setup/common.sh"
source "$git_dir/linux/debian/setup/args.sh"

# install packages needed for zsh
zsh_install() {
    local packages="zsh"

    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite=false
    local input="$g_input"
    local input_required=false
    local install_string='install zsh'
    local overwrite_string=
    local uninstall_string='uninstall zsh'
    exists_cmd() { which zsh &> /dev/null; }
    install_cmd() { echo "$packages" | xargs sudo apt-get -y install ; }
    uninstall_cmd() { echo "$packages" | xargs sudo apt-get --auto-remove -y purge; }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd
    
    return $ret
}

# oh-my-zsh install
omz_install() {
    local omz_dir="$HOME/.oh-my-zsh"

    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite=false
    local input="$g_input"
    local input_required=false
    local install_string='install oh-my-zsh'
    local overwrite_string=
    local uninstall_string='uninstall oh-my-zsh'
    exists_cmd() { [[ -d "$omz_dir" ]]; }
    install_cmd() { sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"; }
    uninstall_cmd() { 
        if [[ ! -x "$omz_dir/tools/uninstall.sh" ]] && ! chmod +x "$omz_dir/tools/uninstall.sh" ; then
            return 1
        fi

        "$omz_dir/tools/uninstall.sh"
    }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd
    
    return $ret
}

# install powerlevel10k
p10k_install() {
    local omz_dir="$HOME/.oh-my-zsh"
    local p10k_dir="$omz_dir/custom/themes/powerlevel10k"

    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite=false
    local input="$g_input"
    local input_required=false
    local install_string='install powerlevel10k'
    local overwrite_string=
    local uninstall_string='uninstall powerlevel10k'
    exists_cmd() { [[ -d "$p10k_dir" ]]; }
    install_cmd() { git clone https://github.com/romkatv/powerlevel10k.git "$p10k_dir"; }
    uninstall_cmd() { rm -rf "$p10k_dir"; }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd
    
    return $ret
}

# set powerlevel10k as the ZSH_THEME
p10k_theme() {
    local omz_theme="$(sed -n $'s/^ZSH_THEME=[\'"]\\(.\\+\\)[\'"]$/\\1/p' "$HOME/.zshrc")"

    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite="$g_overwrite"
    local input="$g_input"
    local input_required=false 
    local install_string='set zsh theme to powerlevel10k/powerlevel10k'
    local overwrite_string="overwrite zsh theme from $omz_theme to powerlevel10k/powerlevel10k"
    local uninstall_string='set zsh theme back to the default theme'
    # todo: could have another command that is passed in that's something like "skip_condition". 
    #       it would be just like it sounds, a condition that would say whether or not to skip
    #       the setup task. in this particular case, the exists command would be checking
    #       the existence of 'ZSH_THEME=', while the skip condition would be to skip if 
    #       ZSH_THEME="powerlevel10k/powerlevel10k"
    # exists_cmd() { [[ "$omz_theme" == 'powerlevel10k/powerlevel10k' ]]; }
    exists_cmd() { [[ -n "$omz_theme" ]]; }
    install_cmd() { 
        if exists_cmd ; then
            sed -i 's/\(^ZSH_THEME=\).\+$/\1"powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        else 
            echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
        fi 
    }
    uninstall_cmd() { sed -i 's/\(^ZSH_THEME=\).\+$/\1"robbyrussell"/' "$HOME/.zshrc"; }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd
    
    return $ret
}

# install custom powerlevel10k profile
p10k_profile() {
    local git_p10k_profile="$git_dir/linux/debian/p10k.zsh"

    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite="$g_overwrite"
    local input="$g_input"
    local input_required=false
    local install_string="install git repo's powerlevel10k profile"
    local overwrite_string='backup and overwrite current powerlevel10k profile'
    local uninstall_string="uninstall git repo's powerlevel10k profile"
    exists_cmd() { [[ -f "$HOME/.p10k.zsh" ]] ; }
    install_cmd() {
        p10k_profile_lines=('#!'"${zsh_shell}")
        if exists_cmd ; then
            p10k_backup="$HOME/.p10k_$(date +%Y%m%d%H%M%S).zsh"
            cp "$HOME/.p10k.zsh" "$p10k_backup"
            # copy failed, don't overwrite
            if [[ "$?" != 0 ]] ; then
                false; return
            fi
            p10k_profile_lines+=("# previous .p10k.zsh profile backed up to ${p10k_backup}")
        fi
        p10k_profile_lines+=("source '$git_p10k_profile'")
        printf "%s\n" "${p10k_profile_lines[@]}" > "$HOME/.p10k.zsh"
    }
    uninstall_cmd() {
        # todo: restore old p10k profile
        rm -f 
    }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd
    
    return $ret
}

# set up powerlevel10k config
p10k_config() {
    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite=false
    local input="$g_input"
    local input_required=false
    local install_string='use installed powerlevel10k config'
    local overwrite_string=
    local uninstall_string='stop using installed powerlevel10k config'
    exists_cmd() { grep '\[\[ ! -f \(\$HOME\|~\)\/\.p10k\.zsh \]\] || source \(\$HOME\|~\)\/\.p10k\.zsh' "$HOME/.zshrc" &> /dev/null ; }
    install_cmd() {
        echo '' >> "$HOME/.zshrc"
        echo '# To customize prompt, run `p10k configure`  or edit ~/.p10k.zsh.' >> "$HOME/.zshrc"
        echo '[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh' >> "$HOME/.zshrc"
    }
    uninstall_cmd() {
        # fine if this first command fails
        sed -i '/# To customize prompt, run `p10k configure`  or edit ~\/.p10k.zsh./d' "$HOME/.zshrc"
        sed -i '/\[\[ ! -f \(\$HOME\|~\)\/\.p10k\.zsh \]\] || source \(\$HOME\|~\)\/\.p10k\.zsh/d' "$HOME/.zshrc"
    }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd
    
    return $ret
}

# add custom zsh profile
zsh_profile() {
    local git_zsh_profile="$git_dir/linux/debian/profile.zsh"
    
    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite=false
    local input="$g_input"
    local input_required=false
    local install_string="use git repo's zsh profile"
    local overwrite_string=
    local uninstall_string="stop using git repo's zsh profile"
    exists_cmd() { grep "source \"$git_zsh_profile\"" "$HOME/.zshrc" &> /dev/null; }
    install_cmd() { echo "source \"$git_zsh_profile\"" >> "$HOME/.zshrc"; }
    uninstall_cmd() { sed -i "/source \"$git_zsh_profile\"/d" "$HOME/.zshrc"; }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd
    
    return $ret
}

# set default shell to zsh
zsh_shell() {
    local zsh_shell="$(which zsh)"
    # todo: restore previous shell instead of defaulting to bash for uninstall.
    local bash_shell="$(which bash)"
    
    local setup_type="$g_setup_type"
    local ask="$g_ask"
    local overwrite="$g_overwrite"
    local input="$g_input"
    local input_required=false
    local install_string=
    local overwrite_string="change shell from $SHELL to $zsh_shell"
    local uninstall_string="change shell from $SHELL to $bash_shell"
    exists_cmd() { [[ "$SHELL" == "$zsh_shell" ]]; }
    install_cmd() { chsh -s "$zsh_shell"; }
    uninstall_cmd() { chsh -s "$bash_shell"; }
    run_setup_task "$setup_type" "$ask" "$overwrite" "$input" "$input_required" "$install_string" "$overwrite_string" "$uninstall_string" 'exists_cmd' 'install_cmd' 'uninstall_cmd'
    local ret=$?

    unset -f exists_cmd
    unset -f install_cmd
    unset -f uninstall_cmd
    
    return $ret
}

# returns
#   0 - install requires restart
#   1 - failed install
#   2 - no installs requiring restart
install() {
    local exit_code=2

    zsh_install

    if [[ $? == 1 ]] ; then
        echo "Skipping the rest of the zsh setup."
        return $exit_code
    fi

    omz_install

    if [[ $? == 1 ]] ; then
        echo "Skipping the rest of the zsh setup."
        return $exit_code
    fi

    p10k_install

    if [[ "$?" == 1 ]] ; then
        echo "Skipping the rest of the zsh setup."
        return $exit_code
    fi

    p10k_theme

    if [[ "$?" == 1 ]] ; then
        echo "Skipping the rest of the zsh setup."
        return $exit_code
    fi

    p10k_profile

    if [[ "$?" == 1 ]] ; then
        echo "Skipping the rest of the zsh setup."
        return $exit_code
    elif [[ "$?" == 0 ]] ; then
        exit_code=0
    fi

    p10k_config

    if [[ "$?" == 1 ]] ; then
        echo "Skipping the rest of the zsh setup."
        return $exit_code
    elif [[ "$?" == 0 ]] ; then
        exit_code=0
    fi

    zsh_profile

    if [[ "$?" == 1 ]] ; then
        echo "Skipping the rest of the zsh setup."
        return $exit_code
    elif [[ "$?" == 0 ]] ; then
        exit_code=0
    fi

    # intentionally last, only want to use zsh if everything was set up properly
    zsh_shell

    if [[ "$?" == 1 ]] ; then
        echo "Skipping the rest of the zsh setup."
        return $exit_code
    elif [[ "$?" == 0 ]] ; then
        exit_code=0
    fi

    return $exit_code
}

# returns
#   0 - uninstall requires restart
#   1 - failed uninstall
#   2 - no uninstalls requiring restart
uninstall() {
    local exit_code=2

    zsh_shell

    if [[ $? = 0 ]] ; then
        exit_code=0
    fi

    zsh_profile

    if [[ $? = 0 ]] ; then
        exit_code=0
    fi

    p10k_config

    if [[ $? = 0 ]] ; then
        exit_code=0
    fi

    p10k_profile

    if [[ $? = 0 ]] ; then
        exit_code=0
    fi

    p10k_theme

    if [[ $? = 0 ]] ; then
        exit_code=0
    fi

    p10k_install
    omz_install
    zsh_install
}

if eval "$g_setup_type" ; then 
    echo "***** NOTE: Restart shell when the script is done running *****"
fi
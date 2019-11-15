#!/bin/bash
git_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../" >/dev/null 2>&1 && pwd )"
source "$git_dir/linux/debian/install/common.sh"
source "$git_dir/linux/debian/install/args.sh"

install() {
    needs_restart=false

    # #zsh install
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string='install zsh'
    overwrite_string=
    exists_cmd() { which zsh &> /dev/null; }
    install_cmd() { 
        packages="zsh"
        echo "$packages" | xargs sudo apt-get -y install
    }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'

    if ! exists_cmd ; then
        echo "Couldn't install zsh, skipping the rest of the zsh setup."
        return
    fi

    # add custom zsh profile
    git_zsh_profile="$git_dir/linux/debian/profile.zsh"
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string="install custom zsh profile"
    overwrite_string=
    exists_cmd() { grep "source '$git_zsh_profile'" "$HOME/.zshrc" &> /dev/null; }
    install_cmd() { echo "source '$git_zsh_profile'" >> "$HOME/.zshrc"; }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd' && needs_restart=true
    
    # set default shell to zsh
    zsh_shell="$(which zsh)"
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string='set the default shell to zsh'
    overwrite_string=''
    exists_cmd() { [[ "$(echo "$SHELL")" = "$zsh_shell" ]]; }
    install_cmd() { chsh -s "$zsh_shell"; }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd' && needs_restart=true

    # oh-my-zsh install
    omz_dir="$HOME/.oh-my-zsh"
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string='install oh-my-zsh'
    overwrite_string=
    exists_cmd() { [[ -d "$omz_dir" ]]; }
    install_cmd() { sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"; }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'

    if ! exists_cmd ; then
        echo "Couldn't install oh-my-zsh, skipping the rest of the zsh setup."
        return
    fi

    # install powerlevel10k
    p10k_dir="$omz_dir/custom/themes/powerlevel10k"
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string='install powerlevel10k'
    overwrite_string=
    exists_cmd() { [[ -d "$p10k_dir" ]]; }
    install_cmd() { git clone https://github.com/romkatv/powerlevel10k.git "$p10k_dir"; }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'

    if ! exists_cmd ; then
        echo "Couldn't install powerlevel10k, skipping the rest of the zsh setup."
        return
    fi

    # set powerlevel10k as the ZSH_THEME
    omz_theme="$(sed -n $'s/^ZSH_THEME=[\'"]\\(.\\+\\)[\'"]$/\\1/p' "$HOME/.zshrc")"
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string="set zsh theme to powerlevel10k"
    overwrite_string="overwrite zsh theme from $omz_theme to powerlevel10k/powerlevel10k"
    exists_cmd() { [[ "$omz_theme" = 'powerlevel10k/powerlevel10k' ]]; }
    install_cmd() { sed -i 's/\(^ZSH_THEME=\).\+$/\1"powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"; }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'

    # install custom powerlevel10k profile
    git_p10k_profile="$git_dir/linux/debian/p10k.zsh"
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string="install custom powerlevel10k profile"
    overwrite_string="overwrite current powerlevel10k profile"
    exists_cmd() { [[ -f "$HOME/.p10k.zsh" ]] && grep "source '$git_p10k_profile'" "$HOME/.p10k.zsh" &> /dev/null ; }
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
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd' && needs_restart=true

    # set up powerlevel10k config
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string="use custom powerlevel10k config"
    overwrite_string=
    exists_cmd() { grep '\[\[ ! -f \(\$HOME\|~\)/\.p10k\.zsh \]\] || source \(\$HOME\|~\)/\.p10k\.zsh' "$HOME/.zshrc" &> /dev/null ; }
    install_cmd() {
        echo '' >> "$HOME/.zshrc"
        echo '# To customize prompt, run `p10k configure`  or edit ~/.p10k.zsh.' >> "$HOME/.zshrc"
        echo '[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh' >> "$HOME/.zshrc"
    }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd' && needs_restart=true

    if [ "$needs_restart" = true ]; then
        echo "***** NOTE: Restart terminal when install is completely finished for zsh *****"
    fi
}

install
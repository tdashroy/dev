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
    overwrite_string=''
    exists_cmd() { which zsh &> /dev/null; }
    install_cmd() { 
        packages="zsh"
        echo "$packages" | xargs sudo apt-get -y install
    }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'

    # # oh-my-zsh install
    omz_dir="$HOME/.oh-my-zsh"
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string='install oh-my-zsh'
    overwrite_string=''
    exists_cmd() { [[ -d "$omz_dir" ]]; }
    install_cmd() { sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"; }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd'

    # # install powerlevel10k
    # p10k_dir="$omz_dir/custom/themes/powerlevel10k"
    # if [ ! -d "$p10k_dir" ] ; then 
    #     echo "Installing powerlevel10k..."
    #     git clone https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    #     needs_restart=true
    # fi

    # # set powerlevel10k as the ZSH_THEME
    # if ! grep 'ZSH_THEME="powerlevel10k\/powerlevel10k"' "$HOME/.zshrc" &> /dev/null ; then
    #     echo "Setting default theme to powerlevel10k..."
    #     sed -i 's/ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' "$HOME/.zshrc"
    #     needs_restart=true
    # fi

    # # create ~/.p10k.sh file if it doesn't exist
    # p10k_sh="$HOME/.p10k.sh"
    # if [ ! -f "$p10k_sh" ] ; then
    #     echo "Creating p10k_sh file..."
        
    # elif 
    # fi

    # # ask if ~/.p10k.sh should be replaced


    # # set up powerlevel10k config
    # if ! grep '[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh' "$HOME/.zshrc" &> /dev/null ; then
    #     echo "Setting up powerlevel10k config..."
    #     echo '# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.' >> "$HOME/.zshrc"
    #     echo '[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh' >> "$HOME/.zshrc"
    #     needs_restart=true
    # fi

    # # add custom zsh profile
    # zsh_profile="$git_dir/linux/debian/zsh_profile.sh"
    # if ! grep "source \"$zsh_profile\"" "$HOME/.zshrc" &> /dev/null ; then
    #     echo "Installing custom zsh options..."
    #     echo "source \"$zsh_profile\"" >> "$HOME/.zshrc"
    #     needs_restart=true
    # fi
    
    # set default shell to zsh
    ask="$g_ask"
    overwrite=false
    user_input="$g_user_input"
    user_input_required=false
    install_string='set the default shell to zsh'
    overwrite_string=''
    exists_cmd() { [[ "$(echo "$SHELL")" = "$(which zsh)" ]]; }
    install_cmd() { chsh -s "$(which zsh)"; }
    run_install_task "$ask" "$overwrite" "$user_input" "$user_input_required" "$install_string" "$overwrite_string" 'exists_cmd' 'install_cmd' && needs_restart=true

    if [ "$needs_restart" = true ]; then
        echo "***** NOTE: Restart terminal when install is completely finished for zsh *****"
    fi
}

install
# dev
Windows:
1. Open elevated Powershell
    1. run "windows/setup/setup.ps1"
1. VS Code (optional)
    1. Download and install VS Code
    1. Add "Delugia Nerd Font" to VS Code Font Families
    1. Install "One Dark Pro" theme from marketplace
1. Open Windows Terminal
    1. Hit ctrl+, to open settings. Change all the profiles to have the "colorScheme": "One Half Dark" and "fontFace": "Delugia Nerd Font"

Debian (tested with WSL):
1. Open elevated bash prompt
    1. run "linux/debian/setup/setup.sh"

# todo
1. Test all the windows setup scripts more carefully
1. Setup scripts for things that need manual setup currently
    1. Windows Terminal
        1. App install
        1. Profile setup (just need to figure out how to use powershell core to run the json parsing commands)
    1. VS Code
        1. App install
        1. Settings setup
    1. Vim
        1. Update install script to use new install run-setup-task functions
        1. Mess with vimrc
1. Modify oh-my-posh and oh-my-zsh/powerlevel10k prompts to match exactly

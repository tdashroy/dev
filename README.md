# Windows setup with repo already cloned or downloaded

1. Open elevated Powershell
1. Run `windows/setup/setup.ps1`

# Windows setup without repo already cloned or downloaded

### default arguments
`Invoke-Command -ScriptBlock ([Scriptblock]::Create((Invoke-WebRequest 'https://raw.githubusercontent.com/tdashroy/dev/master/windows/setup/setup.ps1').Content))`

### ask before each setup step
`Invoke-Command -ScriptBlock ([Scriptblock]::Create((Invoke-WebRequest 'https://raw.githubusercontent.com/tdashroy/dev/master/windows/setup/setup.ps1').Content)) -ArgumentList "-a always"`

# todo
1. Test all the windows setup scripts more carefully
1. Setup scripts for things that need manual setup currently
    1. Windows Terminal
        1. App install
    1. Vim
        1. Update install script to use new install run-setup-task functions
        1. Mess with vimrc
1. Modify oh-my-posh and oh-my-zsh/powerlevel10k prompts to match exactly

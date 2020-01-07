# Windows setup with repo already cloned or downloaded

### default arguments 
Open elevated Powershell and run `windows\setup\setup.ps1`

### ask before each setup set
Open elevated Powershell and run `windows\setup\setup.ps1 -a always`

# Windows setup without repo already cloned or downloaded

### default arguments
```
Invoke-Command -ScriptBlock ([Scriptblock]::Create((Invoke-WebRequest 'https://raw.githubusercontent.com/tdashroy/dev/test/windows/setup/setup.ps1').Content))
```

### install git repo to different directory
By default, the setup will clone the repo to `$HOME\source\repos\dev`. If you'd like to install it to another location use the `-i` parameter. 
For example to install it to `C:\dev` instead, you'd run:
```
Invoke-Command -ScriptBlock ([Scriptblock]::Create((Invoke-WebRequest 'https://raw.githubusercontent.com/tdashroy/dev/test/windows/setup/setup.ps1').Content)) -ArgumentList '-i','C:\dev'
```

### ask before each setup step
```
Invoke-Command -ScriptBlock ([Scriptblock]::Create((Invoke-WebRequest 'https://raw.githubusercontent.com/tdashroy/dev/test/windows/setup/setup.ps1').Content)) -ArgumentList '-a','always'
```

# todo
1. Test all the windows setup scripts more carefully
1. Setup scripts for things that need manual setup currently
    1. Windows Terminal
        1. App install
    1. Vim
        1. Update install script to use new install run-setup-task functions
        1. Mess with vimrc
1. Modify oh-my-posh and oh-my-zsh/powerlevel10k prompts to match exactly

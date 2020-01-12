# Windows setup with repo already cloned or downloaded

### Default arguments 
Open elevated Powershell and run `windows\setup\setup.ps1`

### Ask before each setup step
Open elevated Powershell and run `windows\setup\setup.ps1 -a always`

# Windows setup without repo already cloned or downloaded

### Default arguments
```
Invoke-Command -ScriptBlock ([Scriptblock]::Create((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tdashroy/dev/master/windows/setup/setup.ps1')))
```

### Install git repo to different directory
By default, the setup will clone the repo to `$HOME\source\repos\dev`. If you'd like to install it to another location use the `-i` parameter. 
For example to install it to `C:\dev` instead, you'd run:
```
Invoke-Command -ScriptBlock ([Scriptblock]::Create((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tdashroy/dev/master/windows/setup/setup.ps1'))) -ArgumentList '-p','C:\dev'
```

### Ask before each setup step
By default, the setup won't ask before running any of the setup tasks. If you'd rather confirm each setup task with a y/n prompt, use the `-a` parameter with the `always` option. For example: 
```
Invoke-Command -ScriptBlock ([Scriptblock]::Create((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tdashroy/dev/master/windows/setup/setup.ps1'))) -ArgumentList '-a','always'
```

# All Command Line Options

- `-a <ask_option>`: controls when a setup task should prompt the user before attempting to run. The prompt appears on the command line as a simple `[y/n]` option. The different `<ask_option>` values are found below, the default being `overwrite`.  
  - `always`: the user will be prompted for confirmation before each setup task is run. 
  - `never`: the user will never be prompted for confirmation before any setup task is run.
  - `overwrite`: the default value. The user will only be prompted for confirmation in the case a setup task will overwrite something (for example, an existing setting). This only matters if overwriting is turned on with the `-o` flag. If the `-o` flag isn't specified, this value acts the same as `never`. 
- `-i <input_option>`: controls when a setup task that requires user input should be run. The different `<input_option>` values are found below, the default being `new`.
  - `all`: any setup task that requires user input can run, even if it will overwrite a current value. 
  - `new`: the default value. Only run setup tasks that require user input if they won't be overwriting the current value. 
  - `none`: don't run any setup tasks that require user input.
- `-o`: run a setup task even if it would overwrite current settings. 
- `-p <install_path>`: path to clone the git repo to. By default, it will clone to `$HOME\source\repos\dev`. If `setup.ps1` is run from an already cloned repo, the path of that repo will be the default value. If the repo already exists at the location, it won't re-clone.
- `-u`: run uninstall tasks instead of install tasks.

# todo
1. Add restore functionality to setup scripts
1. Setup scripts for things that need manual setup currently
    1. Windows Terminal
        1. App install
    1. Vim
        1. Update install script to use new install run-setup-task functions
        1. Mess with vimrc
1. Modify oh-my-posh and oh-my-zsh/powerlevel10k prompts to match exactly

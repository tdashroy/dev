$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking
$private:args_module = Get-Command -Module args
Import-Module "$git_dir\windows\setup\args.psm1" -DisableNameChecking

if ((Get-ExecutionPolicy).value__ -gt [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned.value__)
{
    Write-Host "Please set the execution policy to allow RemoteSigned scripts to be run."
    Write-Host "To achieve this, you can run the following command from an admin PowerShell:"
    Write-Host "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm"
    return
}

# install git-for-windows
function git-install {    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install git"
    $overwrite_string = ""
    $uninstall_string = "uninstall git"
    function exists_cmd { Get-Command "git.exe" -ErrorAction SilentlyContinue }
    function install_cmd {
        # get latest download url for git-for-windows
        $git_url = "https://api.github.com/repos/git-for-windows/git/releases/latest"
        $asset = Invoke-RestMethod -Method Get -Uri $git_url | % assets | where name -like "*64-bit.exe"
        # download installer
        $installer = "$env:temp\$($asset.name)"
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer
        # run installer
        $install_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=""$git_dir\windows\setup\git_install.inf"""
        Start-Process -FilePath $installer -ArgumentList $install_args -Wait
        $ret = $?
        # update path
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        return $ret
    }
    function uninstall_cmd { 
        # https://github.com/Limech/git-powershell-silent-install/blob/master/git-silent-uninstall.ps1
        $git_install_dir = [System.IO.Path]::GetFullPath((Join-Path $(Get-Command "git.exe" -ErrorAction SilentlyContinue | % Source) "..\.."))
        $uninstaller = "$git_install_dir\$(dir $git_install_dir | where Name -like "unins*.exe" | % Name)"
        $uninstall_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /FORCECLOSEAPPLICATIONS"
        Start-Process -FilePath $uninstaller -ArgumentList $uninstall_args -Wait
        $ret = $?
        if (Test-Path $git_install_dir) { 
            $remove_dir = Start-Process -FilePath powershell.exe -ArgumentList @("-command","Remove-Item -Path '$git_install_dir' -Recurse -Force") -Wait -PassThru -Verb RunAs
            $ret = $remove_dir.ExitCode -eq 0
        }
        # update path
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        return $ret
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# standardize on LF for checkout and commit
function git-autocrlf {
    $autocrlf = git config --global --get core.autocrlf

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "set git autocrlf to input"
    $overwrite_string = "overwrite git autocrlf from $autocrlf to input"
    $uninstall_string = "unset git autocrlf from input"
    function exists_cmd { return $autocrlf -ne $null }
    function install_cmd { git config --global core.autocrlf input; return $? }
    function uninstall_cmd { git config --global --unset-all core.autocrlf input; return $? }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# set git user name
function git-user-name {
    $user_name = git config --global --get user.name

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $true
    $install_string = "set git user name"
    $overwrite_string = "overwrite git user name from $user_name"
    $uninstall_string = "unset git user name from $user_name"
    function exists_cmd { return $user_name -ne $null }
    function install_cmd { 
        $reply = Read-Host "Please enter your git user name: "
        git config --global user.name $reply 
        return $?
    }
    function uninstall_cmd { git config --global --unset-all user.name; return $? }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# set git user email
function git-user-email {
    $user_email = git config --global --get user.email

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $true
    $install_string = "set git user email"
    $overwrite_string = "overwrite git user email from $user_email"
    $uninstall_string = "unset git user email from $user_email"
    function exists_cmd { return $user_email -ne $null }
    function install_cmd { 
        $reply = Read-Host "Please enter your git user email: "
        git config --global user.email $reply 
        return $?
    }
    function uninstall_cmd { git config --global --unset-all user.email; return $? }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# Turn off .orig files after resolving conflicts with git mergetool
function git-keepBackup {
    $keepBackup = git config --global --get mergetool.keepBackup

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "turn off .orig files after resolving conflicts with git mergetool"
    $overwrite_string = "overwrite git mergetool.keepBackup from $keepBackup to false"
    $uninstall_string = "unset git mergetool.keepBackup from false"
    function exists_cmd { return $keepBackup -ne $null }
    function install_cmd { git config --global mergetool.keepBackup false; return $? }
    function uninstall_cmd { git config --global --unset-all mergetool.keepBackup false; return $? }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# Install posh-git for nicer powershell git integration
function posh-git-install {
    $module = "posh-git"

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install $module"
    $overwrite_string = ""
    $uninstall_string = "uninstall $module"
    # todo: change exists_cmd to check for most recent version too
    #       change install_cmd to update to most recent version if needed
    function exists_cmd { return Get-Module -ListAvailable -Name $module }
    function install_cmd { PowerShellGet\Install-Module -Name $module -Scope CurrentUser -AllowClobber }
    function uninstall_cmd { PowerShellGet\Uninstall-Module -Name $module }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# Install oh-my-posh for theming of the powershell prompt
function oh-my-posh-install { 
    $module = "oh-my-posh"

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install $module"
    $overwrite_string = ""
    $uninstall_string = "uninstall $module"
    # todo: change exists_cmd to check for most recent version too
    #       change install_cmd to update to most recent version if needed
    function exists_cmd { return Get-Module -ListAvailable -Name $module }
    function install_cmd { PowerShellGet\Install-Module -Name $module -Scope CurrentUser -AllowClobber }
    function uninstall_cmd { PowerShellGet\Uninstall-Module -Name $module }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function install {
    $ret = git-install

    if ($ret -eq 1) {
        Write-Error "Couldn't install git, skipping the rest of the git configuration."
        return 1
    }

    $ret = git-autocrlf
    $ret = git-user-name
    $ret = git-user-email
    $ret = git-keepBackup
    
    # $ret = posh-git-install
    # if ($ret -eq 1) {
    #     Write-Error "Couldn't install posh-git, skipping the rest of the powershell command line setup"
    # }

    # $ret = oh-my-posh-install

    return 0
}

function uninstall {
    # $ret = oh-my-posh-install
    # $ret = posh-git-install
    $ret = git-keepBackup
    $ret = git-user-email
    $ret = git-user-name
    $ret = git-autocrlf
    $ret = git-install
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($args_module -eq $null) { Remove-Module args }
if ($common_module -eq $null) { Remove-Module common }
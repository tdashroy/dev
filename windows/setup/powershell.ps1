$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking

# parse common args
. "$git_dir\windows\setup\args.ps1" @args

# install powershell profile
function ps-profile {
    $psprofile = "$git_dir\windows\powershell\profile.ps1"

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install powershell profile"
    $overwrite_string = ""
    $uninstall_string = "uninstall powershell profile"
    function exists_cmd { 
        # todo: something real
        return ($setup_type -eq "uninstall")
    }
    function install_cmd {
        # todo: back up current profile if it already exists
        ". $psprofile" | Out-File $profile.CurrentUserCurrentHost
        Write-Host "New profile installed. Please restart powershell for it to take effect."
        return $true
    }
    function uninstall_cmd {
        # todo: restore previous profile
        Remove-Item $profile.CurrentUserCurrentHost
        return $true
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# Install posh-git for nicer git integration
function posh-git-install {
    $module = "posh-git"

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install $module"
    $overwrite_string = "update $module"
    $uninstall_string = "uninstall $module"
    # todo: change exists_cmd to check for most recent version too
    #       change install_cmd to update to most recent version if needed
    function exists_cmd { Get-Module -ListAvailable -Name $module }
    function install_cmd {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
        PowerShellGet\Install-Module -Name $module -Scope CurrentUser -AllowClobber
        $ret = $?
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
        return $ret
    }
    function uninstall_cmd {
        PowerShellGet\Uninstall-Module -Name $module
        return $?
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# Install oh-my-posh for theming of the prompt
function oh-my-posh-install { 
    $module = "oh-my-posh"

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install $module"
    $overwrite_string = "update $module"
    $uninstall_string = "uninstall $module"
    # todo: change exists_cmd to check for most recent version too
    #       change install_cmd to update to most recent version if needed
    function exists_cmd { Get-Module -ListAvailable -Name $module }
    function install_cmd {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
        PowerShellGet\Install-Module -Name $module -Scope CurrentUser -AllowClobber
        $ret = $?
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
        return $ret
    }
    function uninstall_cmd {
        PowerShellGet\Uninstall-Module -Name $module
        return $?
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function install {
    $ret = posh-git-install
    if ($ret -eq 1) {
        Write-Error "Couldn't install posh-git, skipping oh-my-posh install"
    }
    else {
        $ret = oh-my-posh-install
    }

    $ret = ps-profile
    return $ret
}

function uninstall {
    $ret = ps-profile
    $ret = oh-my-posh-install
    $ret = posh-git-install
    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($null -ne $common_module) { Remove-Module common }
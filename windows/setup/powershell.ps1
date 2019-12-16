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

function install {
    $ret = ps-profile
    return $ret
}

function uninstall {
    $ret = ps-profile
    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($common_module -eq $null) { Remove-Module common }
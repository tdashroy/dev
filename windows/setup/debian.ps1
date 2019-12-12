$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking

# parse common args
. "$git_dir\windows\setup\args.ps1" @args

# install git-for-windows
function debian-install {    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $true
    $install_string = "install debian windows subsystem for linux"
    $overwrite_string = ""
    $uninstall_string = "uninstall debian windows subsystem for linux"
    function exists_cmd { Get-Command "debian.exe" -ErrorAction SilentlyContinue }
    function install_cmd {        
        # download appx package
        $download_url = "https://aka.ms/wsl-debian-gnulinux"
        $package = "$env:temp\debian.appx"
        (New-Object System.Net.WebClient).DownloadFile($download_url, $package)
        $ret = $?; if (-not $ret) { return $ret }
        # install appx package
        Add-AppxPackage $package
        $ret = $?; if (-not $ret) { return $ret }
        # initialize
        Start-Process "debian.exe" -Wait
        $ret = $?; return $ret
    }
    function uninstall_cmd { 
        $package = Get-AppxPackage | Where-Object Name -Like "*debian*"
        Remove-AppxPackage $package        
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function install {
    $ret = debian-install
    return $ret
}

function uninstall {
    $ret = debian-install
    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($common_module -eq $null) { Remove-Module common }
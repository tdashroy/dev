$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking

# parse common args
. "$git_dir\windows\setup\args.ps1" @args

# enable Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
function wsl-enable {
    $feature_name = "Microsoft-Windows-Subsystem-Linux"
   
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $true
    $install_string = "enable Windows Subsystem for Linux"
    $overwrite_string = ""
    $uninstall_string = "disable Windows Subsystem for Linux"
    function exists_cmd { (Get-WindowsOptionalFeature -Online -FeatureName $feature_name | ForEach-Object State) -eq "Enabled" }
    function install_cmd {
        Write-Host "When prompted, please restart your system and re-run the setup script"
        Enable-WindowsOptionalFeature -Online -FeatureName $feature_name
        return $?
    }
    function uninstall_cmd { 
        Disable-WindowsOptionalFeature -Online -FeatureName $feature_name -NoRestart
        $ret = $?
        Write-Host "Once uninstall script is finished running, please restart your machine for changes to take full effect"
        return $ret
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# install git-for-windows
function debian-install {    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
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
        Start-Process -FilePath "debian.exe" -ArgumentList "install" -Wait -NoNewWindow
        $ret = $?; if (-not $ret) { return $ret }
        Start-Process -FilePath "debian.exe" -ArgumentList "-c sudo apt-get update && sudo apt-get -y upgrade" -Wait -NoNewWindow
    }
    function uninstall_cmd { 
        $package = Get-AppxPackage | Where-Object Name -Like "*debian*"
        Remove-AppxPackage $package   
        return $?     
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# run through debian setup tasks
function debian-setup {
    $setup_args = ''
    foreach ($x in $g_args.GetEnumerator()) {
        $setup_args += "-$(if($x.Name.Length -ne 1){'-'})$($x.Name) $($x.Value)"
    }

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $true
    $install_string = "run through debian install tasks"
    $overwrite_string = ""
    $uninstall_string = "run through debian uninstall tasks"
    function exists_cmd { 
        # todo: maybe change this to something real? might actually be fine...tho it's pretty gross
        return ((Get-Command "wsl" -ErrorAction SilentlyContinue) -and ($setup_type -eq "uninstall"))
    }
    function install_cmd {
        $debian_setup_script = wsl wslpath -a "$git_dir\linux\debian\setup\setup.sh".Replace("\", "\\")
        $debian_setup_cmd = "'$debian_setup_script' $setup_args"
        Start-Process -FilePath "debian.exe" -ArgumentList "-c $debian_setup_cmd" -Wait -NoNewWindow
        return $?
    }
    function uninstall_cmd {
        $debian_setup_script = wsl wslpath -a "$git_dir\linux\debian\setup\setup.sh".Replace("\", "\\")
        $debian_setup_cmd = "'$debian_setup_script' $setup_args"
        Start-Process -FilePath "debian.exe" -ArgumentList "-c $debian_setup_cmd" -Wait -NoNewWindow
        return $?        
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function install {
    $ret = wsl-enable

    switch($ret) {
        0 { 
            # don't want to continue if we had to enable wsl
            exit 0 
        }
        1 { 
            Write-Error "Skipping the rest of the debian setup"
            return $ret 
        }
    }

    $ret = debian-install
    $ret = debian-setup
    return $ret
}

function uninstall {
    $ret = debian-setup
    $ret = debian-install
    $ret = wsl-enable
    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($null -eq $common_module) { Remove-Module common }
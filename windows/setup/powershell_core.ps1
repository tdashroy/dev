$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking

# parse common args
. "$git_dir\windows\setup\args.ps1" @args

# install powershell core
function pscore-install {    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install powershell core"
    $overwrite_string = ""
    $uninstall_string = "uninstall powershell core"
    function exists_cmd { Get-Command "pwsh.exe" -ErrorAction SilentlyContinue }
    function install_cmd {
        # get latest download url for powershell core 64-bit exe
        $git_url = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $asset = Invoke-RestMethod -Method Get -Uri $git_url | ForEach-Object assets | Where-Object name -like "*win-x64.msix"
        $ret = $?; if (-not $ret) { return $ret }
        # download installer
        $download_url = $asset.browser_download_url
        $package = "$env:temp\$($asset.name)"
        (New-Object System.Net.WebClient).DownloadFile($download_url, $package)
        $ret = $?; if (-not $ret) { return $ret }
        # run installer
        Add-AppxPackage $package
        $ret = $?; return $ret
    }
    function uninstall_cmd { 
        $package = Get-AppxPackage | Where-Object Name -Like "*powershell*"
        Remove-AppxPackage $package
        return $?
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# Install posh-git for nicer git integration
function posh-git-install {
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install posh-git for PowerShell Core"
    $overwrite_string = "update posh-git for PowerShell Core"
    $uninstall_string = "uninstall posh-git for PowerShell Core"
    # todo: change exists_cmd to check for most recent version too
    function exists_cmd { return pwsh -c { Get-Module -ListAvailable -Name "posh-git" } }
    function install_cmd {
        return pwsh -c {
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
            PowerShellGet\Install-Module -Name "posh-git" -Scope CurrentUser -AllowPrerelease -AllowClobber
            $ret = $?
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
            return $ret
        }
    }
    function uninstall_cmd {
        return pwsh -c {
            PowerShellGet\Uninstall-Module -Name "posh-git"
            return $?
        }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# Install oh-my-posh for theming of the prompt
function oh-my-posh-install {
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install oh-my-posh for PowerShell Core"
    $overwrite_string = "update oh-my-posh for PowerShell Core"
    $uninstall_string = "uninstall oh-my-posh for PowerShell Core"
    # todo: change exists_cmd to check for most recent version too
    function exists_cmd { return pwsh -c { Get-Module -ListAvailable -Name "oh-my-posh" } }
    function install_cmd {
        return pwsh -c {
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
            PowerShellGet\Install-Module -Name "oh-my-posh" -Scope CurrentUser -AllowPrerelease -AllowClobber
            $ret = $?
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
            return $ret
        }
    }
    function uninstall_cmd {
        return pwsh -c {
            PowerShellGet\Uninstall-Module -Name "oh-my-posh"
            return $?
        }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# install powershell core profile
function pscore-profile {
    $psprofile = "$git_dir\windows\powershell\profile.ps1"
    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install powershell core profile"
    $overwrite_string = ""
    $uninstall_string = "uninstall powershell core profile"
    function exists_cmd { 
        # todo: something real
        return ($setup_type -eq "uninstall")
    }
    function install_cmd {
        # todo: back up current profile if it already exists
        pwsh -c { 
            if (-not (Test-Path (Split-Path $PROFILE.CurrentUserCurrentHost))) {
                New-Item -ItemType Directory -Path (Split-Path $PROFILE.CurrentUserCurrentHost)
            }
        }
        Start-Process pwsh -Verb RunAs -Wait -ArgumentList '-NoProfile', '-EncodedCommand', ([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("'. $psprofile' | Out-File " + '$profile.CurrentUserCurrentHost')))
        return $?
    }
    function uninstall_cmd {
        # todo: restore previous profile
        return pwsh -c { Remove-Item $profile.CurrentUserCurrentHost }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function install {
    $ret = pscore-install
        
    $ret = posh-git-install
    if ($ret -eq 1) {
        Write-Error "Couldn't install posh-git, skipping oh-my-posh install"
    }
    else {
        $ret = oh-my-posh-install
    }

    $ret = pscore-profile
    return $ret
}

function uninstall {
    $ret = pscore-profile
    $ret = oh-my-posh-install
    $ret = posh-git-install
    $ret = pscore-install
    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($null -eq $common_module) { Remove-Module common }
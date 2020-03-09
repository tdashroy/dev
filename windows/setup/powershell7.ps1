$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking

# parse common args
. "$git_dir\windows\setup\args.ps1" @args

# install powershell 7
function ps7-install {    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install powershell 7"
    $overwrite_string = ""
    $uninstall_string = "uninstall powershell 7"
    function exists_cmd { Get-Command "pwsh.exe" -ErrorAction SilentlyContinue }
    function install_cmd {
        # get latest download url for powershell 7 64-bit exe
        $git_url = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $asset = Invoke-RestMethod -Method Get -Uri $git_url | ForEach-Object assets | Where-Object name -like "*win-x64.msi"
        $ret = $?; if (-not $ret) { return $ret }
        # download installer
        $download_url = $asset.browser_download_url
        $package = "$env:temp\$($asset.name)"
        (New-Object System.Net.WebClient).DownloadFile($download_url, $package)
        $ret = $?; if (-not $ret) { return $ret }
        # run installer
        $install_args = "/package ""$package"" /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1"
        Start-Process -FilePath "msiexec.exe" -ArgumentList $install_args -Wait
        $ret = $?; if (-not $ret) { return $ret }
        # update path
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        return $ret;
    }
    function uninstall_cmd { 
        # get latest download url for powershell 7 64-bit exe
        $git_url = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $asset = Invoke-RestMethod -Method Get -Uri $git_url | ForEach-Object assets | Where-Object name -like "*win-x64.msi"
        $ret = $?; if (-not $ret) { return $ret }
        # download installer
        $download_url = $asset.browser_download_url
        $package = "$env:temp\$($asset.name)"
        (New-Object System.Net.WebClient).DownloadFile($download_url, $package)
        $ret = $?; if (-not $ret) { return $ret }
        # run installer
        $uninstall_args = "/uninstall ""$package"" /quiet"
        Start-Process -FilePath "msiexec.exe" -ArgumentList $uninstall_args -Wait
        $ret = $?; if (-not $ret) { return $ret }
        # update path
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        return $ret;
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# Install posh-git for nicer git integration
function ps7-posh-git-install {
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install posh-git for PowerShell 7"
    $overwrite_string = "update posh-git for PowerShell 7"
    $uninstall_string = "uninstall posh-git for PowerShell 7"
    # todo: change exists_cmd to check for most recent version too
    function exists_cmd { return pwsh -NoProfile -c { Get-Module -ListAvailable -Name "posh-git" } }
    function install_cmd {
        return pwsh -NoProfile -c {
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
            PowerShellGet\Install-Module -Name "posh-git" -Scope CurrentUser -AllowPrerelease -AllowClobber
            $ret = $?
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
            return $ret
        }
    }
    function uninstall_cmd {
        return pwsh -NoProfile -c {
            PowerShellGet\Uninstall-Module -Name "posh-git"
            return $?
        }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# Install oh-my-posh for theming of the prompt
function ps7-oh-my-posh-install {
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install oh-my-posh for PowerShell 7"
    $overwrite_string = "update oh-my-posh for PowerShell 7"
    $uninstall_string = "uninstall oh-my-posh for PowerShell 7"
    # todo: change exists_cmd to check for most recent version too
    function exists_cmd { return pwsh -NoProfile -c { Get-Module -ListAvailable -Name "oh-my-posh" } }
    function install_cmd {
        return pwsh -NoProfile -c {
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
            PowerShellGet\Install-Module -Name "oh-my-posh" -Scope CurrentUser -AllowPrerelease -AllowClobber
            $ret = $?
            Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
            return $ret
        }
    }
    function uninstall_cmd {
        return pwsh -NoProfile -c {
            PowerShellGet\Uninstall-Module -Name "oh-my-posh"
            return $?
        }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# install powershell 7 profile
function ps7-profile {
    $psprofile = "$git_dir\windows\powershell\profile.ps1"
    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install powershell 7 profile"
    $overwrite_string = ""
    $uninstall_string = "uninstall powershell 7 profile"
    function exists_cmd { 
        # todo: something real
        return ($setup_type -eq "uninstall")
    }
    function install_cmd {
        # todo: back up current profile if it already exists
        # create directory if it doesn't exist
        pwsh -NoProfile -c { 
            if (-not (Test-Path (Split-Path $profile.CurrentUserCurrentHost))) {
                New-Item -ItemType Directory -Path (Split-Path $profile.CurrentUserCurrentHost)
            }
        }
        # add powershell profile
        $command = "'. ''$psprofile''' | Out-File " + '$profile.CurrentUserCurrentHost'
        $bytes = [Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        pwsh -NoProfile -EncodedCommand $encodedCommand
        return $?
    }
    function uninstall_cmd {
        # todo: restore previous profile
        return pwsh -NoProfile -c { Remove-Item $profile.CurrentUserCurrentHost }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function install {
    $ret = ps7-install
        
    $ret = ps7-posh-git-install
    if ($ret -eq 1) {
        Write-Error "Couldn't install posh-git, skipping oh-my-posh install"
    }
    else {
        $ret = ps7-oh-my-posh-install
    }

    $ret = ps7-profile
    return $ret
}

function uninstall {
    $ret = ps7-profile
    $ret = ps7-oh-my-posh-install
    $ret = ps7-posh-git-install
    $ret = ps7-install
    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($null -eq $common_module) { Remove-Module common }
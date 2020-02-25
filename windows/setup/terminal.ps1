$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking

# parse common args
. "$git_dir\windows\setup\args.ps1" @args

# install windows terminal
function terminal-install {
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install Windows Terminal"
    $overwrite_string = ""
    $uninstall_string = "uninstall Windows Terminal"
    function exists_cmd { Get-Command "wt.exe" -ErrorAction SilentlyContinue }
    function install_cmd {
        # todo: figure out a way to install
        Write-Host "Please open the Microsoft Store and install Windows Terminal (Preview)."
        Write-Host "Press any key to open the Microsoft Store..."
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Start-Process "ms-windows-store:"
        Write-Host "Press any key when you're done installing..."
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if (-not (exists_cmd)) { return $false }
        $p = Start-Process "wt.exe" -PassThru
        Start-Sleep -Seconds 5
        Stop-Process $p
        return $true
    }
    function uninstall_cmd {
        # todo: figure out a way to uninstall
        Write-Host "Please open Settings remove the Windows Terminal (Preview)."
        Write-Host "Press any key to continue when done uninstalling..."
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if (exists_cmd) { return $false }
        return $true
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# setup terminal color scheme
function terminal-colorScheme {
    # todo: move this into exists/install/uninstall functions
    # powershell core 6 or greater must be available
    if (-not (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue) -or (pwsh -c {$PSVersionTable.PSVersion.Major}) -lt 6) {
        return 1
    }
    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "set Windows Terminal color scheme to One Half Dark"
    $overwrite_string = ""
    $uninstall_string = "set Windows Terminal color scheme back to Campbell"
    function exists_cmd { 
        return pwsh -NoProfile -c {
            $profiles_json = "$($env:LOCALAPPDATA)\Packages\$(Get-AppxPackage | Where-Object Name -Like "*WindowsTerminal*" | ForEach-Object PackageFamilyName)\LocalState\profiles.json"
            # todo: create a new profile
            if (-Not (Test-Path $profiles_json)) { return $false }
            # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
            $jobj = Get-Content $profiles_json | ConvertFrom-Json
            # check that the default color scheme is set to "One Half Dark"
            return ($jobj.profiles.defaults.colorScheme -eq "One Half Dark")
        }
    }
    function install_cmd {
        return pwsh -NoProfile -c {
            $profiles_json = "$($env:LOCALAPPDATA)\Packages\$(Get-AppxPackage | Where-Object Name -Like "*WindowsTerminal*" | ForEach-Object PackageFamilyName)\LocalState\profiles.json"
            # todo: create a new profile
            if (-Not (Test-Path $profiles_json)) { return $false }
            # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
            $jobj = Get-Content $profiles_json | ConvertFrom-Json
            if ($jobj.profiles.defaults.colorScheme) {
                # change default colorScheme
                $jobj.profiles.defaults.colorScheme = "One Half Dark"
            }
            else {
                # add default colorScheme
                Add-Member -InputObject $jobj.profiles.defaults -MemberType NoteProperty -Name "colorScheme" -Value "One Half Dark"
            }
            # convert back to json and write to file. we lose the comments, but not sure how to easily handle that
            # todo: add comments back
            $jobj | ConvertTo-Json -Depth 5 | Out-File $profiles_json
            return $true
        }
    }
    function uninstall_cmd {
        return pwsh -NoProfile -c {
            $profiles_json = "$($env:LOCALAPPDATA)\Packages\$(Get-AppxPackage | Where-Object Name -Like "*WindowsTerminal*" | ForEach-Object PackageFamilyName)\LocalState\profiles.json"
            # todo: create a new profile
            if (-Not (Test-Path $profiles_json)) { return $false }
            # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
            $jobj = Get-Content $profiles_json | ConvertFrom-Json
            # remove default colorScheme
            $jobj.profiles.defaults.PSObject.Properties.Remove("colorScheme")
            # convert back to json and write to file. we lose the comments, but not sure how to easily handle that
            # todo: add comments back
            $jobj | ConvertTo-Json -Depth 5 | Out-File $profiles_json
            return $true
        }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# setup terminal font
function terminal-fontFace {  
    # todo: move this into exists/install/uninstall functions
    # powershell core 6 or greater must be available
    if (-not (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue) -or (pwsh -c {$PSVersionTable.PSVersion.Major}) -lt 6) {
        return 1
    }
    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "set Windows Terminal font to Delugia Nerd Font"
    $overwrite_string = "set Windows Terminal font to Delugia Nerd Font"
    $uninstall_string = "set Windows Terminal font back to Consolas"
    function exists_cmd { 
        return pwsh -NoProfile -c {
            $profiles_json = "$($env:LOCALAPPDATA)\Packages\$(Get-AppxPackage | Where-Object Name -Like "*WindowsTerminal*" | ForEach-Object PackageFamilyName)\LocalState\profiles.json"
            # todo: create a new profile
            if (-Not (Test-Path $profiles_json)) { return $false }
            # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
            $jobj = Get-Content $profiles_json | ConvertFrom-Json
            # check that all profiles use the font "Delugia Nerd Font"
            return ($jobj.profiles.defaults.fontFace -eq "Delugia Nerd Font")
        }
    }
    function install_cmd {
        return pwsh -NoProfile -c {
            $profiles_json = "$($env:LOCALAPPDATA)\Packages\$(Get-AppxPackage | Where-Object Name -Like "*WindowsTerminal*" | ForEach-Object PackageFamilyName)\LocalState\profiles.json"
            # todo: create a new profile
            if (-Not (Test-Path $profiles_json)) { return $false }
            # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
            $jobj = Get-Content $profiles_json | ConvertFrom-Json
            if ($jobj.profiles.defaults.fontFace) {
                # change default fontFace
                $jobj.profiles.defaults.fontFace = "Delugia Nerd Font"
            }
            else {
                # add default fontFace
                Add-Member -InputObject $jobj.profiles.defaults -MemberType NoteProperty -Name "fontFace" -Value "Delugia Nerd Font"
            }
            # convert back to json and write to file. we lose the comments, but not sure how to easily handle that
            # todo: add comments back
            $jobj | ConvertTo-Json -Depth 5 | Out-File $profiles_json
            return $true
        }
    }
    function uninstall_cmd {
        return pwsh -NoProfile -c {
            $profiles_json = "$($env:LOCALAPPDATA)\Packages\$(Get-AppxPackage | Where-Object Name -Like "*WindowsTerminal*" | ForEach-Object PackageFamilyName)\LocalState\profiles.json"
            # todo: create a new profile
            if (-Not (Test-Path $profiles_json)) { return $false }
            # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
            $jobj = Get-Content $profiles_json | ConvertFrom-Json
            # remove default fontFace
            $jobj.profiles.defaults.PSObject.Properties.Remove("fontFace")
            # convert back to json and write to file. we lose the comments, but not sure how to easily handle that
            # todo: add comments back
            $jobj | ConvertTo-Json -Depth 5 | Out-File $profiles_json
            return $true
        }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# set default terminal shell to debian
function terminal-debiandefault {  
    # todo: move this into exists/install/uninstall functions
    # powershell core 6 or greater must be available
    if (-not (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue) -or (pwsh -c {$PSVersionTable.PSVersion.Major}) -lt 6) {
        return 1
    }
    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "set default Windows Terminal profile to Debian"
    $overwrite_string = ""
    $uninstall_string = "set default Windows Terminal profile back to Windows PowerShell"
    function exists_cmd { 
        return pwsh -NoProfile -c {
            $profiles_json = "$($env:LOCALAPPDATA)\Packages\$(Get-AppxPackage | Where-Object Name -Like "*WindowsTerminal*" | ForEach-Object PackageFamilyName)\LocalState\profiles.json"
            # todo: create a new profile
            if (-Not (Test-Path $profiles_json)) { return $false }
            # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
            $jobj = Get-Content $profiles_json | ConvertFrom-Json
            $debian_guid = $jobj.profiles.list | Where-Object name -eq "Debian" | ForEach-Object guid
            if ($debian_guid -eq $null) { return $false }
            # check if the default guid is debian
            return ($jobj.defaultProfile -eq $debian_guid)
        }
    }
    function install_cmd {
        return pwsh -NoProfile -c {
            $profiles_json = "$($env:LOCALAPPDATA)\Packages\$(Get-AppxPackage | Where-Object Name -Like "*WindowsTerminal*" | ForEach-Object PackageFamilyName)\LocalState\profiles.json"
            # todo: create a new profile
            if (-Not (Test-Path $profiles_json)) { return $false }
            # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
            $jobj = Get-Content $profiles_json | ConvertFrom-Json
            $debian_guid = $jobj.profiles.list | Where-Object name -eq "Debian" | ForEach-Object guid
            if ($debian_guid -eq $null) { return $false }
            $jobj.defaultProfile = $debian_guid
            # convert back to json and write to file. we lose the comments, but not sure how to easily handle that
            # todo: add comments back
            $jobj | ConvertTo-Json -Depth 5 | Out-File $profiles_json
            return $true
        }
    }
    function uninstall_cmd {
        # todo: uninstall command if pwsh is not available
        return pwsh -NoProfile -c {
            $profiles_json = "$($env:LOCALAPPDATA)\Packages\$(Get-AppxPackage | Where-Object Name -Like "*WindowsTerminal*" | ForEach-Object PackageFamilyName)\LocalState\profiles.json"
            # todo: create a new profile
            if (-Not (Test-Path $profiles_json)) { return $false }
            # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
            $jobj = Get-Content $profiles_json | ConvertFrom-Json
            # change each profile's colorScheme and fontFace
            $ps_guid = $jobj.profiles.list | Where-Object name -eq "Windows PowerShell" | ForEach-Object guid
            if ($ps_guid -eq $null) { return $false }
            $jobj.defaultProfile = $ps_guid
            # convert back to json and write to file. we lose the comments, but not sure how to easily handle that
            # todo: add comments back
            $jobj | ConvertTo-Json -Depth 5 | Out-File $profiles_json
            return $true
        }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function install {
    $ret = terminal-install

    if ($ret -eq 1) {
        Write-Error "Windows Terminal not installed, skipping rest of terminal setup"
    }

    $ret = terminal-colorScheme
    $ret = terminal-fontFace
    $ret = terminal-debiandefault

    return $ret
}

function uninstall {
    $ret = terminal-debiandefault
    $ret = terminal-fontFace
    $ret = terminal-colorScheme
    $ret = terminal-install
    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($null -eq $common_module) { Remove-Module common }
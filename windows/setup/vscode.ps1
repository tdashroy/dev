$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking

# parse common args
. "$git_dir\windows\setup\args.ps1" @args

# install vscode
function vscode-install {    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install Visual Studio Code"
    $overwrite_string = ""
    $uninstall_string = "uninstall Visual Studio Code"
    function exists_cmd { Get-Command "code" -ErrorAction SilentlyContinue }
    function install_cmd {
        # download installer
        $download_url = "https://aka.ms/win32-x64-user-stable"
        $installer = "$env:temp\vscode_installer.exe"
        (New-Object System.Net.WebClient).DownloadFile($download_url, $installer)
        $ret = $?; if (-not $ret) { return $ret }
        # run installer
        $install_args = "/SP- /SILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /MERGETASKS=!runcode"
        Start-Process -FilePath $installer -ArgumentList $install_args -Wait
        $ret = $?; if (-not $ret) { return $ret }
        # update path
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        return $ret
    }
    function uninstall_cmd { 
        $install_dir = [System.IO.Path]::GetFullPath((Join-Path $(Get-Command "code" -ErrorAction SilentlyContinue | ForEach-Object Source) "..\.."))
        $uninstaller = "$install_dir\$(dir $install_dir | Where-Object Name -like "unins*.exe" | ForEach-Object Name)"
        $uninstall_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /FORCECLOSEAPPLICATIONS"
        Start-Process -FilePath $uninstaller -ArgumentList $uninstall_args -Wait
        $ret = $?; if (-not $ret) { return $ret }
        if (Test-Path $install_dir) { 
            $remove_dir = Start-Process -FilePath powershell.exe -ArgumentList @("-command","Remove-Item -Path '$install_dir' -Recurse -Force") -Wait -PassThru -Verb RunAs
            $ret = $remove_dir.ExitCode -eq 0; if (-not $ret) { return $ret }
        }
        # update path
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        return $ret
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function vscode-ext-remote-wsl {
    $extension = "ms-vscode-remote.remote-wsl"

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install Visual Studio Code remote-wsl extension"
    $overwrite_string = ""
    $uninstall_string = "uninstall Visual Studio Code remote-wsl extension"
    function exists_cmd { return ((Get-Command "code" -ErrorAction SilentlyContinue) -and ((code --list-extensions | Where-Object { $_ -eq $extension }) -ne $null)) }
    function install_cmd {
        code --install-extension $extension
        return $?
    }
    function uninstall_cmd {
        code --uninstall-extension $extension
        return $?
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function vscode-ext-powershell {
    $extension = "ms-vscode.powershell"

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install Visual Studio Code powershell extension"
    $overwrite_string = ""
    $uninstall_string = "uninstall Visual Studio Code powershell extension"
    function exists_cmd { return ((Get-Command "code" -ErrorAction SilentlyContinue) -and ((code --list-extensions | Where-Object { $_ -eq $extension }) -ne $null)) }
    function install_cmd {
        code --install-extension $extension
        return $?
    }
    function uninstall_cmd {
        code --uninstall-extension $extension
        return $?
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function vscode-ext-one-dark-pro {
    $extension = "zhuangtongfa.material-theme"

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install Visual Studio Code One Dark Pro theme"
    $overwrite_string = ""
    $uninstall_string = "uninstall Visual Studio Code One Dark Pro theme"
    function exists_cmd { return ((Get-Command "code" -ErrorAction SilentlyContinue) -and ((code --list-extensions | Where-Object { $_ -eq $extension }) -ne $null)) }
    function install_cmd {
        code --install-extension $extension
        return $?
    }
    function uninstall_cmd {
        code --uninstall-extension $extension
        return $?
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# setup visual studio code font to one dark pro
function vscode-setting-one-dark-pro {   
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
    $install_string = "set Visual Studio Code color theme to One Dark Pro"
    $overwrite_string = "overwrite Visual Studio Code color theme to One Dark Pro"
    $uninstall_string = "set Visual Studio Code color theme back to default"
    function exists_cmd {
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        return pwsh -c {
            $settings_json = "$($env:APPDATA)\Code\User\settings.json"
            return ((Test-Path $settings_json) -and ((Get-Content $settings_json | ConvertFrom-Json)."workbench.colorTheme" -eq "One Dark Pro"))
        }
    }
    function install_cmd {
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        return pwsh -c {
            $settings_json = "$($env:APPDATA)\Code\User\settings.json"
    
            if (Test-Path $settings_json) {
                $jobj = Get-Content $settings_json | ConvertFrom-Json
            }
            else {
                $jobj = New-Object -TypeName PSCustomObject
            }
    
            if (Get-Member -InputObject $jobj -Name "workbench.colorTheme") {
                $jobj."workbench.colorTheme" = "One Dark Pro"
            }
            else {
                Add-Member -InputObject $jobj -MemberType NoteProperty -Name "workbench.colorTheme" -Value "One Dark Pro"
            }
            
            $jobj | ConvertTo-Json | Out-File $settings_json
            return $true
        }
    }
    function uninstall_cmd {
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        return pwsh -c {
            $settings_json = "$($env:APPDATA)\Code\User\settings.json"
    
            if (-Not (Test-Path $settings_json)) {
                return $false
            }
            $jobj = Get-Content $settings_json | ConvertFrom-Json
    
            if (-Not (Get-Member -InputObject $jobj -Name "workbench.colorTheme")) {
                return $false
            }
            $jobj.PSObject.Properties.Remove("workbench.colorTheme")
            
            $jobj | ConvertTo-Json | Out-File $settings_json
            return $true
        }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# setup visual studio code font to Delugia Nerd Font
function vscode-setting-fontFamily {   
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
    $install_string = "set Visual Studio Code font to Delugia Nerd Font"
    $overwrite_string = ""
    $uninstall_string = "set Visual Studio Code font back to default"
    function exists_cmd {
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        return pwsh -c {
            $settings_json = "$($env:APPDATA)\Code\User\settings.json"
            return ((Test-Path $settings_json) -and ((Get-Content $settings_json | ConvertFrom-Json)."editor.fontFamily" -like "*'Delugia Nerd Font',*"))
        }
    }
    function install_cmd {
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        return pwsh -c {
            $settings_json = "$($env:APPDATA)\Code\User\settings.json"
    
            if (Test-Path $settings_json) {
                $jobj = Get-Content $settings_json | ConvertFrom-Json
            }
            else {
                $jobj = New-Object -TypeName PSCustomObject
            }
    
            if (Get-Member -InputObject $jobj -Name "editor.fontFamily") {
                $jobj."editor.fontFamily" = "'Delugia Nerd Font', " + $jobj."editor.fontFamily"
            }
            else {
                Add-Member -InputObject $jobj -MemberType NoteProperty -Name "editor.fontFamily" -Value "'Delugia Nerd Font', Consolas, 'Courier New', monospace"
            }
            
            $jobj | ConvertTo-Json | Out-File $settings_json
            return $true
        }
    }
    function uninstall_cmd {
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        return pwsh -c {
            $settings_json = "$($env:APPDATA)\Code\User\settings.json"
    
            if (-Not (Test-Path $settings_json)) {
                return $false
            }
            $jobj = Get-Content $settings_json | ConvertFrom-Json
    
            if (-Not (Get-Member -InputObject $jobj -Name "editor.fontFamily")) {
                return $false
            }
            $jobj.PSObject.Properties.Remove("editor.fontFamily")
            
            $jobj | ConvertTo-Json | Out-File $settings_json
            return $true
        }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# setup visual studio code font to Delugia Nerd Font
function vscode-setting-fontLigatures {   
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
    $install_string = "turn off Visual Studio Code font ligatures"
    $overwrite_string = "turn off Visual Studio Code font ligatures"
    $uninstall_string = "set Visual Studio Code font ligatures back to default"
    function exists_cmd {
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        return pwsh -c {
            $settings_json = "$($env:APPDATA)\Code\User\settings.json"
            return ((Test-Path $settings_json) -and (((Get-Content $settings_json | ConvertFrom-Json)."editor.fontLigatures") -eq $false))
        }
    }
    function install_cmd {
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        return pwsh -c {
            $settings_json = "$($env:APPDATA)\Code\User\settings.json"
    
            if (Test-Path $settings_json) {
                $jobj = Get-Content $settings_json | ConvertFrom-Json
            }
            else {
                $jobj = New-Object -TypeName PSCustomObject
            }
    
            if (Get-Member -InputObject $jobj -Name "editor.fontLigatures") {
                $jobj."editor.fontLigatures" = $false
            }
            else {
                Add-Member -InputObject $jobj -MemberType NoteProperty -Name "editor.fontLigatures" -Value $false
            }
            
            $jobj | ConvertTo-Json | Out-File $settings_json
            return $true
        }
    }
    function uninstall_cmd {
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        return pwsh -c {
            $settings_json = "$($env:APPDATA)\Code\User\settings.json"
    
            if (-Not (Test-Path $settings_json)) {
                return $false
            }
            $jobj = Get-Content $settings_json | ConvertFrom-Json
    
            if (-Not (Get-Member -InputObject $jobj -Name "editor.fontLigatures")) {
                return $false
            }
            $jobj.PSObject.Properties.Remove("editor.fontLigatures")
            
            $jobj | ConvertTo-Json | Out-File $settings_json
            return $true
        }
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function install {
    $ret = vscode-install

    if ($ret -eq 1) {
        Write-Error "Skipping the rest of the Visual Studio Code configuration."
        return 1
    }

    $ret = vscode-ext-remote-wsl
    $ret = vscode-ext-powershell
    
    $ret = vscode-ext-one-dark-pro
    if ($ret -ne 1) {
        $ret = vscode-setting-one-dark-pro
    }

    $ret = vscode-setting-fontFamily
    $ret = vscode-setting-fontLigatures

    return $ret
}

function uninstall {
    $ret = vscode-setting-fontLigatures
    $ret = vscode-setting-fontFamily
    $ret = vscode-setting-one-dark-pro
    $ret = vscode-ext-one-dark-pro
    $ret = vscode-ext-powershell
    $ret = vscode-ext-remote-wsl
    $ret = vscode-install

    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($null -ne $common_module) { Remove-Module common }
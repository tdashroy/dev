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
        $install_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /MERGETASKS=!runcode"
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

# setup visual studio code font to Delugia Nerd Font
function vscode-font {   
    # todo: need to make sure we're running pwsh for this
    return 0
    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "set Visual Studio Code font to Delugia Nerd Font"
    $overwrite_string = "set Visual Studio Code font to Delugia Nerd Font"
    $uninstall_string = "set Visual Studio Code font back to Consolas"
    function exists_cmd { return $true }
    function install_cmd {
        $settings_json = "$env:APPDATA\Code\User\settings.json"
        # todo: create a new profile
        if (-Not (Test-Path $settings_json)) {
            return $false
        }
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        $jobj = Get-Content $settings_json | ConvertFrom-Json
        # change each profile's colorScheme and fontFace
        $jobj | ForEach-Object { 
            if ($_ -ne $null) {
                if (Get-Member -InputObject $_ -Name colorScheme) {
                    $_.colorScheme = "One Half Dark"
                }
                else {
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name "colorScheme" -Value "One Half Dark"
                }
            }
        }
        # convert back to json and write to file. we lose the comments, but not sure how to easily handle that
        # todo: add comments back
        $jobj | ConvertTo-Json | Out-File $profiles_json
    }
    function uninstall_cmd {
        $profiles_json = "C:\Users\tdash\AppData\Local\Packages\$(Get-AppxPackage | Where-Object Name -Like "*WindowsTerminal*" | ForEach-Object PackageFamilyName)\LocalState\profiles.json"
        # todo: create a new profile
        if (-Not (Test-Path $profiles_json)) {
            return $false
        }
        # parse json (requires PowerShell Core 6.0 or later to parse comments in the file)
        $jobj = Get-Content $profiles_json | ConvertFrom-Json
        # change each profile's colorScheme and fontFace
        $jobj.profiles | ForEach-Object { 
            if ($_ -ne $null) {
                if (Get-Member -InputObject $_ -Name colorScheme) {
                    $_.colorScheme = "Campbell"
                }
                else {
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name "colorScheme" -Value "Campbell"
                }
            }
        }
        # convert back to json and write to file. we lose the comments, but not sure how to easily handle that
        # todo: add comments back
        $jobj | ConvertTo-Json | Out-File $profiles_json

    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function install {
    $ret = vscode-install

    if ($ret -eq 1) {
        Write-Error "Skipping the rest of the Visual Studio Code configuration."
        return 1
    }

    return $ret
}

function uninstall {
    $ret = vscode-install

    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($common_module -eq $null) { Remove-Module common }
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
        Write-Host "Please open the Microsoft Store and install the Windows Terminal (Preview)."
        Write-Host "Press any key to continue when done installing..."
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if (-not (exists_cmd)) {
            return $false
        }
        return $true
    }
    function uninstall_cmd {
        # todo: figure out a way to uninstall
        Write-Host "Please open Settings remove the Windows Terminal (Preview)."
        Write-Host "Press any key to continue when done uninstalling..."
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if (exists_cmd) {
            return $false
        }
        return $true
    }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

# setup terminal profile
function terminal-colorScheme {   
    # todo: need to make sure we're running pwsh for this
    return 0
    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "set Windows Terminal color scheme to One Half Dark"
    $overwrite_string = "set Windows Terminal color scheme to One Half Dark"
    $uninstall_string = "set Windows Terminal color scheme back to Campbell"
    function exists_cmd { return $true }
    function install_cmd {
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

# setup terminal profile
function terminal-fontFace {  
    # todo: need to make sure we're running pwsh for this
    return 0
    
    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "set Windows Terminal font to Delugia Nerd Font"
    $overwrite_string = "set Windows Terminal font to Delugia Nerd Font"
    $uninstall_string = "set Windows Terminal font back to Consolas"
    function exists_cmd { return $true }
    function install_cmd {
        # todo: figure out how to run all these commands in pwsh
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
                if (Get-Member -InputObject $_ -Name fontFace) {
                    $_.fontFace = "Delugia Nerd Font"
                }
                else {
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name "fontFace" -Value "Delugia Nerd Font"
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
                if (Get-Member -InputObject $_ -Name fontFace) {
                    $_.fontFace = "Consolas"
                }
                else {
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name "fontFace" -Value "Consolas"
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
    $ret = terminal-install

    if ($ret -eq 1) {
        Write-Error "Windows Terminal not installed, skipping rest of terminal setup"
    }

    $ret = terminal-colorScheme
    $ret = terminal-fontFace

    return $ret
}

function uninstall {
    $ret = terminal-fontFace
    $ret = terminal-colorScheme
    $ret = terminal-install
    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($common_module -eq $null) { Remove-Module common }
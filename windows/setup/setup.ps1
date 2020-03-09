# check for elevation
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {    
    # If PSCommandPath is empty, assume we're running the script as a ScriptBlock in memory, as opposed to the script being stored somewhere
    if (!$PSCommandPath) {
        Write-Host "This script requires admin privelages to run, please re-run from an elevated powershell prompt" -ForegroundColor $host.PrivateData.ErrorForegroundColor
        return
    }
    Start-Process PowerShell -Verb RunAs "-NoExit -NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath' $args;`"";
    return
}

# check execution policy
if (((Get-ExecutionPolicy).value__ -ne [Microsoft.PowerShell.ExecutionPolicy]::Bypass.value__) -and ((Get-ExecutionPolicy).value__ -ne [Microsoft.PowerShell.ExecutionPolicy]::Unrestricted.value__))
{
    Write-Host "Please set the execution policy to Bypass scripts to be run." -ForegroundColor $host.PrivateData.ErrorForegroundColor
    Write-Host "To achieve this, you can run the following command from an admin PowerShell:" -ForegroundColor $host.PrivateData.ErrorForegroundColor
    Write-Host "Set-ExecutionPolicy Bypass -Scope CurrentUser -Confirm" -ForegroundColor $host.PrivateData.ErrorForegroundColor
    return
}

try 
{
    # need to get install path out first
    for ($i = 0; $i -lt $args.Count; ++$i) {
        switch -Regex ($args[$i])
        {
            "-p|-Path" { 
                $install_path = $args[++$i]
                break
            }
        }
    }

    # if install_path wasn't specified with a command line option, set its value
    if (!$install_path) {
        # not running from script, so just default to $HOME\source\repos\dev
        if (!$MyInvocation.MyCommand.Path) {
            $install_path = "$HOME\source\repos\dev"
        }
        else {
            $install_path = [System.IO.Path]::GetFullPath((Join-Path (Split-Path $MyInvocation.MyCommand.Path) "..\.."))
        }
    }

    # check if the $install_path\windows\setup\setup.ps1 already exists. if it does, assume our repo is already cloned there
    # todo: probably a better way to do this...
    $tmp_base_dir = $null
    if (Test-Path "$install_path\windows\setup\setup.ps1") {
        $git_dir = "$install_path"
    }
    else {
        $tmp_base_dir = "$($env:TEMP)\dev_$(Get-Date -Format yyyyMMdd-hhmmss)"
        New-Item -Path "$tmp_base_dir\windows\setup" -ItemType Directory

        # download files needed for installing git
        $repo_url = "https://raw.githubusercontent.com/tdashroy/dev/master/windows/setup"
        ("common.psm1", "args.ps1", "git.ps1", "git_install.inf") | ForEach-Object {
            (New-Object System.Net.WebClient).DownloadFile("$repo_url/$_", "$tmp_base_dir\windows\setup\$_")
            if (-not $?) { 
                Write-Error "Failed to download required file $repor_url/$_, exiting."
                return
            }
        }

        # temporarily set git_dir to the temp directory that has  the files needed for installing git
        $git_dir = $tmp_base_dir
    }

    # load modules
    $private:common_module = Get-Command -Module common
    Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking
    . "$git_dir\windows\setup\args.ps1" @args

    # # run git setup script before everything else, in case git isn't installed yet
    & "$git_dir\windows\setup\git.ps1"

    # if setup was run outside of the git repo dir, clone the repo into the $install_path
    if ($null -ne $tmp_base_dir) {
        if (-not (Test-Path "$install_path")) {
            New-Item -ItemType Directory -Path $install_path
        }

        $repo_url = "https://github.com/tdashroy/dev.git"
        git clone "https://github.com/tdashroy/dev.git" "$install_path"
        if (-not $?) { 
            Write-Error "Failed to clone $repo_url, exiting."
            return
        }

        # change git_dir to the directory of the newly cloned repo
        $git_dir = "$install_path"
    }

    # run the rest of the setup scripts
    & "$git_dir\windows\setup\debian.ps1"
    & "$git_dir\windows\setup\font.ps1"
    & "$git_dir\windows\setup\powershell.ps1"
    & "$git_dir\windows\setup\powershell7.ps1"
    & "$git_dir\windows\setup\terminal.ps1"
    & "$git_dir\windows\setup\vscode.ps1"
}
finally 
{
    # unload modules if this script loaded them
    if ($null -eq $common_module) { 
        Remove-Module common 
    }

    # if setup was run outside of the git repo dir, clean up after ourselves
    if ($null -ne $tmp_base_dir) {
        Remove-Item $tmp_base_dir -Recurse -Force
    }
}
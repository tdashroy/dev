Param(
    [Parameter(Mandatory=$false)]
    [Alias("i", "Path", "p")]
    [String] $InstallDir = "$HOME\source\repos\dev",

    [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)]
    $Rest
)

# elevate if not already
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # build bound parameter list for forwarding
    $bound_params = $PSBoundParameters.GetEnumerator() | Where-Object { $_.Key -ne "Rest" } | ForEach-Object {
        $param_str = ''
        if ($null -ne $_.Key) {
            $param_str += '-' + $_.Key.ToString() + ' '
        }
        $param_str += $_.Value.ToString() + ' '
        $param_str
    }
    
    Start-Process PowerShell -Verb RunAs "-NoExit -NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath' $bound_params $Rest;`"";
    exit;
}

# check execution policy
if (((Get-ExecutionPolicy).value__ -ne [Microsoft.PowerShell.ExecutionPolicy]::Bypass.value__) -and ((Get-ExecutionPolicy).value__ -ne [Microsoft.PowerShell.ExecutionPolicy]::Unrestricted.value__))
{
    Write-Host "Please set the execution policy to Bypass scripts to be run."
    Write-Host "To achieve this, you can run the following command from an admin PowerShell:"
    Write-Host "Set-ExecutionPolicy Bypass -Scope CurrentUser -Confirm"
    return
}

# build unbound parameter map for splatting later (for some reason splatting $Rest doesn't work...)
$unbound_params = @{}
$last = $null
foreach ($x in $Rest) {
    if ($x -match '^-') {
        $last = $x -replace '^-'
        $unbound_params[$last] = $null
    }
    else {
        $unbound_params[$last] = $x
    }
}

$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# check if the InstallDir\windows\setup\setup.ps1 already exists. if it does, assume our repo is already cloned there
# todo: probably a better way to do this...
$tmp_base_dir = $null
if (Test-Path "$InstallDir\windows\setup\setup.ps1") {
    $git_dir = "$InstallDir"
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
            Exit 1
        }
    }

    # temporarily set git_dir to the temp directory with the files needed for installing git
    $git_dir = $tmp_base_dir
}

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking
. "$git_dir\windows\setup\args.ps1" @unbound_params

# run git setup script before everything else, in case git isn't installed yet
& "$git_dir\windows\setup\git.ps1"

# if setup was run outside of the git repo dir, clone the repo into the InstallDir
if ($null -ne $tmp_base_dir) {
    if (-not (Test-Path "$InstallDir")) {
        New-Item -ItemType Directory -Path $InstallDir
    }

    $repo_url = "https://github.com/tdashroy/dev.git"
    git clone "https://github.com/tdashroy/dev.git" "$InstallDir"
    if (-not $?) { 
        Write-Error "Failed to clone $repo_url, exiting."
        exit 1
    }

    # change git_dir to the directory of the newly cloned repo
    $git_dir = "$InstallDir"
}

# run the rest of the setup scripts
& "$git_dir\windows\setup\debian.ps1" @unbound_params
& "$git_dir\windows\setup\font.ps1"
& "$git_dir\windows\setup\powershell.ps1"
& "$git_dir\windows\setup\powershell_core.ps1"
& "$git_dir\windows\setup\terminal.ps1"
& "$git_dir\windows\setup\vscode.ps1"

# unload modules if this script loaded them
if ($null -ne $common_module) { Remove-Module common }

# if setup was run outside of the git repo dir, clean up after ourselves
if ($null -ne $tmp_base_dir) {
    Remove-Item $tmp_base_dir -Recurse -Force
}
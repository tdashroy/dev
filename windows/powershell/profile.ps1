$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load functions and aliases
Import-Module "$git_dir\windows\powershell\functions\colors.psm1"
Import-Module "$git_dir\windows\powershell\functions\cd.psm1"
Import-Module "$git_dir\windows\powershell\functions\git.psm1"
Import-Module "$git_dir\windows\powershell\aliases\cd.psm1"
Import-Module "$git_dir\windows\powershell\aliases\git.psm1"

# Make powershell tab complete unix-like
Set-PSReadlineKeyHandler -Key Tab -Function Complete

# Turn off beeps
Set-PSReadlineOption -BellStyle None

# set up posh-git if it's available
if (Get-Module -ListAvailable -Name "posh-git") 
{
    Import-Module posh-git
}

# set up oh-my-posh if it's available
if (Get-Module -ListAvailable -Name "oh-my-posh") 
{
    Import-Module oh-my-posh
    # Set default user to current user so that the username and prompt don't show up in the prompt
    $DefaultUser = [System.Environment]::UserName

    Set-Theme "$git_dir\windows\powershell\themes\OneHalfDarkParadox.psm1"
}

# Local powershell profile, for machine specific settings
$lprofile = "$git_dir\windows\powershell\lprofile.ps1"
if (Test-Path $lprofile)
{
    . $lprofile
}

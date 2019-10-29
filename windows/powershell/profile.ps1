$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

Import-Module "$git_dir\windows\powershell\external\git.psm1"
# . $git_dir\windows\powershell\console\prompt.ps1
Import-Module "$git_dir\windows\powershell\console\oh-my-posh.psm1"
Import-Module "$git_dir\windows\powershell\functions\colors.psm1"
Import-Module "$git_dir\windows\powershell\functions\cd.psm1"
Import-Module "$git_dir\windows\powershell\aliases\cd.psm1"
Import-Module "$git_dir\windows\powershell\functions\git.psm1"
Import-Module "$git_dir\windows\powershell\aliases\git.psm1"

# Local powershell profile, for machine specific settings
$lprofile = "$git_dir\windows\powershell\lprofile.ps1"
if (Test-Path $lprofile)
{
    . $lprofile
}

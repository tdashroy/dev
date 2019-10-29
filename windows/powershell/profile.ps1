$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# . $git_dir\windows\powershell\console\colors.ps1
. $git_dir\windows\powershell\modules\git.ps1
# . $git_dir\windows\powershell\console\prompt.ps1
. $git_dir\windows\powershell\console\oh-my-posh.ps1
. $git_dir\windows\powershell\functions\colors.ps1
. $git_dir\windows\powershell\functions\cd.ps1
. $git_dir\windows\powershell\aliases\cd.ps1
. $git_dir\windows\powershell\functions\git.ps1
. $git_dir\windows\powershell\aliases\git.ps1

# Local powershell profile, for machine specific settings
$lprofile = "$git_dir\windows\powershell\lprofile.ps1"
if (Test-Path $lprofile)
{
    . $lprofile
}

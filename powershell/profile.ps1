$dot = Split-Path $MyInvocation.MyCommand.Path

. $dot\modules\posh-git.ps1
. $dot\console\colors.ps1
. $dot\console\prompt.ps1
. $dot\functions\colors.ps1
. $dot\functions\cd.ps1
. $dot\aliases\cd.ps1

# Local powershell profile, for machine specific settings
$lprofile = "$dot\lprofile.ps1"
if (Test-Path $lprofile)
{
    . $lprofile
}

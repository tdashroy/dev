$dot = Split-Path $MyInvocation.MyCommand.Path

. $dot\posh-git.ps1
. $dot\prompt.ps1

# Local powershell profile, for machine specific settings
$lprofile = "$dot\lprofile.ps1"
if (Test-Path $lprofile)
{
    . $lprofile
}

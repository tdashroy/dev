$dot = Split-Path $MyInvocation.MyCommand.Path

# powershell git
. $dot\posh-git.ps1
# prompt modifications
. $dot\prompt.ps1

# Local powershell profile, for machine specific settings
. $dot\lprofile.ps1

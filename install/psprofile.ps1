$dot = Split-Path $MyInvocation.MyCommand.Path
". $dot\..\powershell\profile.ps1" | Out-File $profile.CurrentUserCurrentHost -Force
. $profile.CurrentUserCurrentHost

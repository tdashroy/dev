$dot = Split-Path $MyInvocation.MyCommand.Path
$psprofile = [System.IO.Path]::GetFullPath((Join-Path $dot "..\powershell\profile.ps1"))
". $psprofile" | Out-File $profile.CurrentUserCurrentHost -Force
. $profile.CurrentUserCurrentHost
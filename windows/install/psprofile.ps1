$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))
$psprofile = "$git_dir\windows\powershell\profile.ps1"
". $psprofile" | Out-File $profile.CurrentUserCurrentHost -Force
Write-Host "New profile installed. Please restart powershell for it to take effect."

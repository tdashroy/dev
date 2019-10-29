$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))
. $git_dir\windows\install\git.ps1
. $git_dir\windows\install\psprofile.ps1

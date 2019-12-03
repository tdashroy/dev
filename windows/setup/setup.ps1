$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking
$private:args_module = Get-Command -Module args
Import-Module "$git_dir\windows\setup\args.psm1" -DisableNameChecking

& "$git_dir\windows\install\git.ps1"
# & "$git_dir\windows\install\psprofile.ps1"

# unload modules if this script loaded 
if ($args_module -eq $null) { Remove-Module args }
if ($common_module -eq $null) { Remove-Module common }
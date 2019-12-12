# elevate if not already
f (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

# check execution policy
if ((Get-ExecutionPolicy).value__ -gt [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned.value__)
{
    Write-Host "Please set the execution policy to allow RemoteSigned scripts to be run."
    Write-Host "To achieve this, you can run the following command from an admin PowerShell:"
    Write-Host "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm"
    return
}

$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking
. "$git_dir\windows\setup\args.ps1" @args

& "$git_dir\windows\setup\font.ps1"
& "$git_dir\windows\setup\git.ps1"
& "$git_dir\windows\setup\debian.ps1"
& "$git_dir\windows\setup\terminal.ps1"
& "$git_dir\windows\setup\powershell.ps1"
& "$git_dir\windows\setup\powershell_core.ps1"

# unload modules if this script loaded them
if ($common_module -eq $null) { Remove-Module common }
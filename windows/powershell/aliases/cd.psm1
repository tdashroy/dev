$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\..\.."))

Import-Module "$git_dir\windows\powershell\functions\cd.psm1"
Set-Alias -Name cd -value cddash -Option AllScope

Export-ModuleMember -Function * -Variable * -Alias *
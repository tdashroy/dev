$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\..\.."))

Import-Module "$git_dir\windows\powershell\functions\git.psm1"

Set-Alias -Name git-branch-cleanup -value gitBranchCleanup -Option AllScope

Export-ModuleMember -Function * -Variable * -Alias *
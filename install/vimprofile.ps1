$dotdir = Split-Path $MyInvocation.MyCommand.Path

# Using ASCII because otherwise vim gets confused.
$vimrc = [System.IO.Path]::GetFullPath((Join-Path $dotdir "..\vim\_vimrc"))
"execute 'source ' . fnameescape('$vimrc')" | Out-File ~\_vimrc -Encoding ASCII -Force

$gvimrc = [System.IO.Path]::GetFullPath((Join-Path $dotdir "..\vim\_gvimrc"))
"execute 'source ' . fnameescape('$gvimrc')" | Out-File ~\_gvimrc -Encoding ASCII -Force

﻿$dot = Split-Path $MyInvocation.MyCommand.Path
$vimrc = [System.IO.Path]::GetFullPath((Join-Path $dot "..\vim\_vimrc"))
"execute 'source ' . fnameescape('$vimrc')" | Out-File ~\_vimrc -Encoding ASCII -Force

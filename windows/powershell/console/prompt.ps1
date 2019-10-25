﻿function global:prompt {
    $origLastExitCode = $LASTEXITCODE

    # git status, requires posh-git
    Write-VcsStatus

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curPath.ToLower().StartsWith($Home.ToLower()))
    {
        $curPath = "~" + $curPath.SubString($Home.Length)
    }

    Write-Host $curPath -ForegroundColor Green
    $LASTEXITCODE = $origLastExitCode
    "$('>' * ($nestedPromptLevel + 1)) "
}

# Make powershell tab complete unix-like
# Set-PSReadlineKeyHandler -Key Tab -Function Complete

# Turn off beeps
Set-PSReadlineOption -BellStyle None

# posh-git prompt settings
$global:GitPromptSettings.BeforeText = '['
$global:GitPromptSettings.AfterText  = '] '
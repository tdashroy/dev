function global:prompt {
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

# posh-git prompt settings
$global:GitPromptSettings.BeforeText = '['
$global:GitPromptSettings.AfterText  = '] '
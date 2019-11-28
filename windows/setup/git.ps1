if ((Get-ExecutionPolicy).value__ -gt [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned.value__)
{
    Write-Host "Please set the execution policy to allow RemoteSigned scripts to be run."
    Write-Host "To achieve this, you can run the following command from an admin PowerShell:"
    Write-Host "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm"
    return
}

# standardize on LF for checkout and commit
function git-autocrlf {
    $autocrlf = git config --global --get core.autocrlf

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $g_overwrite
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "set git autocrlf to input"
    $overwrite_string = "overwrite git autocrlf from $autocrlf to input"
    $uninstall_string = "unset git autocrlf from input"
    function exists_cmd { $autocrlf -eq $null }
    function install_cmd { git config --global core.autocrlf input }
    function uninstall_cmd { git config --global --unset-all core.autocrlf input }
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { overwrite_cmd } { uninstall_cmd }
}

# Turn off .orig files after resolving conflicts with git mergetool
git config --global mergetool.keepBackup false

# Install posh-git for nicer powershell git integration
Write-Host "Installing posh-git..."
PowerShellGet\Install-Module posh-git -Scope CurrentUser -AllowClobber
Write-Host "Done installing posh-git."

# Install oh-my-posh for theming of the powershell prompt
Write-Host "Installing oh-my-posh..."
PowerShellGet\Install-Module oh-my-posh -Scope CurrentUser -AllowClobber
Write-Host "Done installing oh-my-posh."
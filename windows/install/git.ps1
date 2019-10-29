if ((Get-ExecutionPolicy).value__ -gt [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned.value__)
{
    Write-Host "Please set the execution policy to allow RemoteSigned scripts to be run."
    Write-Host "To achieve this, you can run the following command from an admin PowerShell:"
    Write-Host "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm"
    return
}

# Make line endings checkout Windows-style and commit Unix-style
git config --global core.autocrlf true

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
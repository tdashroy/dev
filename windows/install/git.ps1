if ((Get-ExecutionPolicy).value__ -gt [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned.value__)
{
    Write-Host "Please set the execution policy to allow RemoteSigned scripts to be run."
    Write-Host "To achieve this, you can run the following command from an admin PowerShell:"
    Write-Host "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm"
    return
}

PowerShellGet\Install-Module posh-git -Scope CurrentUser -AllowClobber
PowerShellGet\Install-Module oh-my-posh -Scope CurrentUser -AllowClobber

# Make line endings checkout Windows-style and commit Unix-style
git config --global core.autocrlf true

# Turn off .orig files after resolving conflicts with git mergetool
git config --global mergetool.keepBackup false

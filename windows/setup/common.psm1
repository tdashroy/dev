
enum SetupType {
   Install
   Uninstall 
}

enum Ask {
    Always
    Never
    Overwrite
}

enum UserInput {
    All
    New
    None
}

Function Run-Install-Task {
Param(
    [Ask] $ask
    [bool] $overwrite
    [UserInput] $user_input
    [bool] $input_required
    [String] $install_string
    [String] $overwrite_string
    [ScriptBlock] $exists_cmd
    [ScriptBlock] $install_cmd
)
    if ($input_required -eq $true -and $user_input -eq UserInput::None)
    {
        return 2
    }

    $task_string = $install_string
    $exists = $false

    & $exists_cmd
    if ($lastexitcode -eq 0)
    {
        if ($overwrite -ne $true -or ($input_required -eq $true -and $input_required -ne UserInput::All))
        {
            return 2
        }
        $task_string = $overwrite_string
        $exists = $true
    }

    if ($ask -eq Ask::Always -or ($exits -eq $true -and $ask -eq Ask::Overwrite))
    {
        <prompt> "Would you like to $($task_string)? [y/n] "
    }

    Write-Host "Running task to $($task_string)..."
    & $install_cmd
    if ($lastexitcode -ne 0)
    {
        Write-Host "Failed to $($task_string)."
        return 1
    }

    return 0
}

Function Run-Uninstall-Task {
Param(
    [Ask] $ask
    [String] $uninstall_string
    [ScriptBlock] $exists_cmd
    [ScriptBlock] $uninstall_cmd
)
    & $exists_cmd
    if ($lastexitcode -ne 0)
    {
        Write-Host "Skipping task to $($uninstall_string)."
        return 2
    }

    if ($ask -eq Ask::Always -or $ask -eq Ask::Overwrite)
    {
        <prompt> "Would you like to $($uninstall_string)? [y/n] "
    }

    Write-Host "Running task to $($uninstall_string)..."
    & $uninstall_cmd
    if ($lastexitcode -ne 0)
    {
        Write-Host "Failed to $($uninstall_string)."
        return 1
    }

    return 0
}

Function Run-Setup-Task {
Param(
    [SetupType] $setup_type
    [Ask] $ask
    [bool] $overwrite
    [UserInput] $user_input
    [bool] $input_required
    [String] $install_string
    [String] $overwrite_string
    [String] $uninstall_string
    [ScriptBlock] $exists_cmd
    [ScriptBlock] $install_cmd
    [ScriptBlock] $uninstall_cmd
)
    if ($setup_type -eq SetupType::Install)
    {
        return Run-Install-Task $ask $overwrite $user_input $input_required $install_string $overwrite_string $exists_cmd $install_cmd
    }
    elseif ($setup_type -eq SetupType::Uninstall)
    {
        return Run-Uninstall-Task $ask $uninstall_string $exists_cmd $uninstall_cmd
    }
    else
    {
        return 1
    }
}

Export-ModuleMember -Function * -Variable * -Alias *
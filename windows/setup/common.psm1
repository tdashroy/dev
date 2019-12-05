# returns
#   0 - successful install
#   1 - install needed, but was not successful
#   2 - no attempted install
Function Run-Install-Task {
Param(
    [String] $ask,
    [bool] $overwrite,
    [String] $user_input,
    [bool] $input_required,
    [String] $install_string,
    [String] $overwrite_string,
    [ScriptBlock] $exists_cmd,
    [ScriptBlock] $install_cmd
)
    if ($input_required -eq $true -and $user_input -eq "none")
    {
        return 2
    }

    $task_string = $install_string
    $exists = $false

    if (& $exists_cmd)
    {
        if ($overwrite -ne $true -or ($input_required -eq $true -and $user_input -ne "all"))
        {
            return 2
        }
        $task_string = $overwrite_string
        $exists = $true
    }

    if ($ask -eq "always" -or ($exists -eq $true -and $ask -eq "overwrite"))
    {
        :ask_loop while ($true)
        {
            $reply = Read-Host "Would you like to $($task_string)? [y/n] "
            switch -Wildcard ($reply)
            {
                "y*" { break ask_loop }
                "n*" { if ($exists -eq $true) { return 2 } else { return 1 } }
            }
        }
    }

    Write-Host "Running task to $($task_string)..."
    if (-not (& $install_cmd))
    {
        Write-Host "Failed to $($task_string)."
        return 1
    }

    return 0
}

# returns
#   0 - successful uninstall
#   1 - uninstall needed, but was not successful
#   2 - uninstall not needed 
Function Run-Uninstall-Task {
Param(
    [String] $ask,
    [String] $uninstall_string,
    [ScriptBlock] $exists_cmd,
    [ScriptBlock] $uninstall_cmd
)
    if (-not (& $exists_cmd))
    {
        Write-Host "Skipping task to $($uninstall_string)."
        return 2
    }

    if ($ask -eq "always" -or $ask -eq "overwrite")
    {
        :ask_loop while ($true)
        {
            $reply = Read-Host "Would you like to $($uninstall_string)? [y/n] "
            switch -Wildcard ($reply)
            {
                "y*" { break ask_loop }
                "n*" { return 1 }
            }
        }

    }

    Write-Host "Running task to $($uninstall_string)..."
    if (-not (& $uninstall_cmd))
    {
        Write-Host "Failed to $($uninstall_string)."
        return 1
    }

    return 0
}

# returns
#   0 - success
#   1 - fail
#   2 - no action
Function Run-Setup-Task {
Param(
    [String] $setup_type,
    [String] $ask,
    [bool] $overwrite,
    [String] $user_input,
    [bool] $input_required,
    [String] $install_string,
    [String] $overwrite_string,
    [String] $uninstall_string,
    [ScriptBlock] $exists_cmd,
    [ScriptBlock] $install_cmd,
    [ScriptBlock] $uninstall_cmd
)
    if ($setup_type -eq "install")
    {
        return Run-Install-Task $ask $overwrite $user_input $input_required $install_string $overwrite_string $exists_cmd $install_cmd
    }
    elseif ($setup_type -eq "uninstall")
    {
        return Run-Uninstall-Task $ask $uninstall_string $exists_cmd $uninstall_cmd
    }
    else
    {
        return 1
    }
}

Export-ModuleMember -Function * -Variable * -Alias *
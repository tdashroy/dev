if ($g_ask -eq $null) { $g_ask = "overwrite" }
if ($g_user_input -eq $null) { $g_user_input = "new" }
# if ($g_overwrite -eq $null) { $g_overwrite = $false }
if ($g_overwrite -eq $null) { $g_overwrite = $false }
if ($g_setup_type -eq $null) { $g_setup_type = "install" }
if ($g_verbose -eq $null) { $g_verbose = $false }

Export-ModuleMember -Function * -Variable * -Alias *
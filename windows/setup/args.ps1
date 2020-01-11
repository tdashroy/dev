if (-not $args_has_run) {
    # build parameter map for splatting (for some reason splatting $args doesn't work when running with as a ScriptBlock with -ArgumentList)
    $g_args = @{}
    $last = $null
    for ($i = 0; $i -lt $args.Count; ++$i) 
    {
        switch -Regex ($args[$i])
        {
            '^-.*' {
                $last = $args[$i] -replace '^-'
                # if this is a switch parameter, setting this to true is what we need
                # if not, it will get overwritten on the next iteration
                $g_args[$last] = $true
                break
            }
            default {
                if ($null -eq $last) {
                    Write-Host "Bad command line argument: $($args[$i])" -ForegroundColor $host.PrivateData.ErrorForegroundColor
                    return
                }
                $g_args[$last] = $args[$i]
                $last = $null
                break
            }
        }
    }

    foreach ($x in $g_args.GetEnumerator()) 
    {
        switch -Regex ($x.Name)
        {
            'a|Ask' {
                if ($x.Value -match 'always|never|overwrite') {
                    $g_ask = $x.Value
                }
                else {
                    Write-Host "Bad value for command line argument $($x.Name): $($x.Value)" -ForegroundColor $host.PrivateData.ErrorForegroundColor
                    return
                }
                break
            }
            'i|UserInput' {
                if ($x.Value -match 'all|new|none') {
                    $g_user_input = $x.Value
                }
                else {
                    Write-Host "Bad value for command line argument $($x.Name): $($x.Value)" -ForegroundColor $host.PrivateData.ErrorForegroundColor
                    return
                }
                break
            }
            'o|Overwrite' {
                if ($x.Value -match 'True|False') {
                    $g_overwrite = $x.Value
                }
                else {
                    Write-Host "Bad value for command line argument $($x.Name): $($x.Value)" -ForegroundColor $host.PrivateData.ErrorForegroundColor
                    return
                }
                break
            }
            'u|Uninstall' {
                if ($x.Value -match 'True|False') {
                    $g_setup_type = If (-not $x.Value) { "install" } Else { "uninstall" }
                }
                else {
                    Write-Host "Bad value for command line argument $($x.Name): $($x.Value)" -ForegroundColor $host.PrivateData.ErrorForegroundColor
                    return
                }
                break
            }
        }
    }

    if ($null -eq $g_ask) { $g_ask = 'overwrite' }
    if ($null -eq $g_user_input) { $g_user_input = 'new' }
    if ($null -eq $g_overwrite) { $g_overwrite = $false }
    if ($null -eq $g_setup_type) { $g_setup_type = 'install' }
    if ($null -eq $g_verbose) { $g_verbose = $false }

    # todo: figure if it's possible to update calling script's $args to not contain the provided parameters

    $args_has_run = $true
}
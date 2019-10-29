function cddash {
    if ($args.Length -eq 1 -and $args[0] -eq '-') {
        $args[0] = $OLDPWD;
    } 
    
    $tmp = $pwd;
    Set-Location @args;

    if ($pwd.Path -ne $tmp.Path) {
        Set-Variable -Name OLDPWD -Value $tmp -Scope global;
    }
}

Export-ModuleMember -Function * -Variable * -Alias *
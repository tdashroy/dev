function gitBranchCleanup {
    Write-Host "Cleaning up local git branches that no longer exist on the remote...";
    git remote prune origin;
    $filtered = git branch -vv | Select-String -InputObject {$_} -Pattern "origin/.*: gone";
    if ($filtered)
    {
        $filtered | 
            ForEach-Object { ($_ -split "\s+")[1]; } |
            ForEach-Object { git branch -D $_; };  
    }
    else 
    {
        Write-Host "No branches to clean up."; 
    }
}

Export-ModuleMember -Function * -Variable * -Alias *
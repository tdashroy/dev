Function Get-ConsoleColor {
Param([switch]$Colorize)
     
    $wsh = New-Object -ComObject wscript.shell;

    $data = [enum]::GetNames([consolecolor]);

    if ($Colorize) {
        Foreach ($color in $data) {
            Write-Host $color -ForegroundColor $Color;
        }
        [void]$wsh.Popup("The current background color is $([console]::BackgroundColor)",16,"Get-ConsoleColor");
    }
    else {
        #display values
        $data;
    }
     
} #Get-ConsoleColor

Function Show-ConsoleColor {
Param()
    $host.PrivateData.psobject.properties | 
    Foreach {
        #$text = "$($_.Name) = $($_.Value)"
        Write-host "$($_.name.padright(23)) = " -NoNewline;
        Write-Host $_.Value -ForegroundColor $_.value;
    };
} #Show-ConsoleColor

Function Test-ConsoleColor {
[cmdletbinding()]
Param()

    Clear-Host;
    $heading = "White";
    Write-Host "Pipeline Output" -ForegroundColor $heading;
    Get-Service | Select -first 5;

    Write-Host "`nError" -ForegroundColor $heading;
    Write-Error "I made a mistake";

    Write-Host "`nWarning" -ForegroundColor $heading;
    Write-Warning "Let this be a warning to you.";

    Write-Host "`nVerbose" -ForegroundColor $heading;
    $VerbosePreference = "Continue";
    Write-Verbose "I have a lot to say.";
    $VerbosePreference = "SilentlyContinue";

    Write-Host "`nDebug" -ForegroundColor $heading;
    $DebugPreference = "Continue";
    Write-Debug "`nSomething is bugging me. Figure it out.";
    $DebugPreference = "SilentlyContinue";

    Write-Host "`nProgress" -ForegroundColor $heading;
    1..10 | foreach -Begin {$i=0} -process {
        $i++;
        $p = ($i/10)*100;
        Write-Progress -Activity "Progress Test" -Status "Working" -CurrentOperation $_ -PercentComplete $p;
        Start-Sleep -Milliseconds 250;
    };
} #Test-ConsoleColor

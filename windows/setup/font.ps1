$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking

# parse common args
. "$git_dir\windows\setup\args.ps1" @args

# install delugia nerd complete font
function delugia-install {
    $font_name = "Delugia Nerd Font"
    $font_filename = "Delugia.Nerd.Font.Complete.ttf"

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install $font_name"
    $overwrite_string = ""
    $uninstall_string = "uninstall $font_name"
    function exists_cmd {
        return (Get-ChildItem -Path C:\Windows\Fonts -Filter $font_filename) -ne $null
    }
    function install_cmd {
        Write-Host "Please right click on $font_filename and click 'Install for all users'."
        Write-Host "Press any key to open explorer to directory with $font_filename..."
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Start-Process "explorer.exe" -ArgumentList "$git_dir"
        Write-Host "Press any key when you're done..."
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if (-not (exists_cmd)) {
            return $false
        }
        return $true
    }
    function uninstall_cmd {
        Write-Host "Please click on $font_name in the font settings and select uninstall"
        Write-Host "Press any key to open settings app..."
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Start-Process "ms-settings:fonts"
        Write-Host "Press any key when you're done..."
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if (exists_cmd) {
            return $false
        }
        return $true
    }
    # todo: doesn't persist across reboot for some reason (even though the file is still there). need to find a way to do this programatically
    ## local machine install
    #function exists_cmd {
    #    # font folder (0x14)
    #    foreach ($f in (New-Object -ComObject Shell.Application).Namespace(0x14).Items()) {
    #        if ($f.Name -Like "$font_name*") { 
    #            return $true
    #        }
    #    }
    #    return $false
    #}
    ## adapted from https://gist.github.com/anthonyeden/0088b07de8951403a643a8485af2709b
    #function install_cmd {
    #    # font folder (0x14), FOF_SILENT (0x4) + FOF_NOCONFIRMATION (0x10)
    #    (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($font_git_path, 0x4 + 0x10)
    #    if (-not (exists_cmd)) {
    #        return $false
    #    }
    #    return $true
    #}
    #function uninstall_cmd {
    #    Write-Host "Please open $((New-Object -ComObject Shell.Application).Namespace(0x14).Self.Path) app and remove the font $font_name."
    #    Write-Host "Press any key to continue when done removing..."
    #    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    #    if (exists_cmd) {
    #        return $false
    #    }
    #    return $true
    #}
    return Run-Setup-Task $setup_type $ask $overwrite $user_input $input_required $install_string $overwrite_string $uninstall_string { exists_cmd } { install_cmd } { uninstall_cmd }
}

function install {
    $ret = delugia-install
    return $ret
}

function uninstall {
    $ret = delugia-install
    return $ret
}

$ret = & $g_setup_type

# unload modules if this script loaded 
if ($null -ne $common_module) { Remove-Module common }
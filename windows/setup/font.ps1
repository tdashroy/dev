$dot = Split-Path $MyInvocation.MyCommand.Path
$git_dir = [System.IO.Path]::GetFullPath((Join-Path $dot "..\.."))

# load modules
$private:common_module = Get-Command -Module common
Import-Module "$git_dir\windows\setup\common.psm1" -DisableNameChecking

# parse common args
. "$git_dir\windows\setup\args.ps1" @args

# install delugia nerd complete font
function delugia-install {
    $font_name = "Delugia Nerd Font (TrueType)"
    $font_filename = "Delugia.Nerd.Font.Complete.ttf"
    $font_git_path = "$git_dir\$font_filename"
    $font_install_path = "$($env:LOCALAPPDATA)\Microsoft\Windows\Fonts\$font_filename"
    $font_reg_path = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

    $setup_type = $g_setup_type
    $ask = $g_ask
    $overwrite = $false
    $user_input = $g_user_input
    $input_required = $false
    $install_string = "install $font_name"
    $overwrite_string = ""
    $uninstall_string = "uninstall $font_name"
    function exists_cmd {
        (Test-Path -Path $font_install_path) -and ((Get-Item -Path $font_reg_path).GetValue($font_name) -eq $font_install_path)
    }
    # local machine install, vs. user install
    # # adapted from https://gist.github.com/anthonyeden/0088b07de8951403a643a8485af2709b and https://www.reddit.com/r/sysadmin/comments/a64lax/windows_1809_breaks_powershell_script_to_install/ebs68wj/
    # function install_cmd {
    #     # font folder (0x14)
    #     $dest = (New-Object -ComObject Shell.Application).Namespace(0x14)
    #     # FOF_SILENT (0x4) + FOF_NOCONFIRMATION (0x10)
    #     $dest.CopyHere($font_path, 0x4 + 0x10)
    #     New-ItemProperty -Name $font_name -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $
    # }
    function install_cmd {
        Copy-Item -Path $font_git_path -Destination $font_install_path -Force
        $ret = $?; if (-not $ret) { return $ret }
        New-ItemProperty -Name $font_name -Path $font_reg_path -PropertyType string -Value $font_install_path
        $ret = $?; return $ret
    }
    function uninstall_cmd {
        Remove-Item -Path $font_install_path -Force
        $ret = $?; if (-not $ret) { return $ret }
        Remove-ItemProperty -Name $font_name -Path $font_reg_path -Force
        $ret = $?; return $ret
    }
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
if ($common_module -eq $null) { Remove-Module common }
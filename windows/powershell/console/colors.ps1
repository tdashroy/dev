
$host.UI.RawUI.ForegroundColor = "White";
$host.UI.RawUI.BackgroundColor = "Black";

# Reset token colors.
# Note: for some reason this needs to go after changing the colors..
Set-PSReadlineOption -ResetTokenColors;

Clear-Host;

# dev
Install order for WSL:
1. Git for Windows
1. Install "windows/Cascadia Code Nerd Font Complete.ttf"
1. Install debian WSL
1. Install Windows Terminal from Microsoft Store
1. VS Code (optional)
  1. Download and install VS Code
  1. Add "CascadiaCode Nerd Font" to VS Code Font Families
  1. Install "One Dark Pro" theme from marketplace
1. Open Windows Terminal
  1. Hit ctrl+, to open settings. Change all the profiles to have the "colorScheme": "One Half Dark" and "fontFace": "CascadiaCode Nerd Font"
  1. In powershell tab, run "windows/install/install.ps1"
  1. In debian tab, run "linux/debian/install/install.sh"
  1. In debian tab, run "linux/debian/install/wsl.sh"

# todo
1. Install scripts for manual install/setup
  1. Git for Windows
  1. Fonts
  1. Windows Terminal
    1. App install
    1. Profile setup
  1. VS Code
    1. App install
    1. Profile setup
1. Modify oh-my-posh and oh-my-zsh/powerlevel10k prompts to match

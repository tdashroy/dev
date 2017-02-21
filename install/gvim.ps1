# Download installer
$url = "ftp://ftp.vim.org/pub/vim/pc/gvim80-069.exe"
$filename = [System.IO.Path]::GetFileName($url)
$output = "$env:TEMP\$filename"
(New-Object System.Net.WebClient).DownloadFile($url, $output)

# Install via installer
#   Note: this requires user input, need to find a way to do silent mode.
Start-Process $output -Wait

# Install path
#   Note: Would be great to fetch this from somewhere instead of hard coding 
$installPath = "${env:ProgramFiles(x86)}\Vim\vim80"

# Add directory to user path
[Environment]::SetEnvironmentVariable("Path", ([Environment]::GetEnvironmentVariable("Path", "User") + ";$installPath"), "User")
$env:Path += ";$installPath"
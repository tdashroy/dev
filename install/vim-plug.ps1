# Install vim-plug 

# Create autoload directory
$output = [System.IO.Path]::GetFullPath((Join-Path (Resolve-Path ~) "\vimfiles\autoload"))
New-Item $output -Type Directory -Force

# Download vim-plug to autoload directory
$url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
$filename = [System.IO.Path]::GetFileName($url)
$output = (Join-Path $output $filename)
(New-Object System.Net.WebClient).DownloadFile($url, $output)
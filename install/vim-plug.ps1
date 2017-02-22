# Install vim-plug 

# Create autoload directory
$output = [System.IO.Path]::GetFullPath((Join-Path (Resolve-Path ~) "\vimfiles\autoload"))
$null = New-Item $output -Type Directory -Force -ErrorAction Stop

# Download vim-plug to autoload directory
$url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
$fileName = [System.IO.Path]::GetFileName($url)
$output = (Join-Path $output $fileName)
(New-Object System.Net.WebClient).DownloadFile($url, $output)
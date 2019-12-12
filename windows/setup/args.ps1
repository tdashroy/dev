Param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("always", "never", "overwrite")]
    [Alias("a")]
    [String] $Ask = "overwrite",

    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "new", "none")]
    [Alias("i")]
    [String] $UserInput = "new",

    [Parameter(Mandatory=$false)]
    [Alias("o")]
    [switch] $Overwrite, 

    [Parameter(Mandatory=$false)]
    [Alias("u")]
    [switch] $Uninstall
)

if (-not $args_has_run) {
    $g_ask = $Ask
    $g_user_input = $UserInput
    $g_overwrite = $Overwrite
    $g_setup_type = If (-not $Uninstall) { "install" } Else { "uninstall" }
    $g_verbose = $false

    # todo: figure if it's possible to update calling script's $args to not contain the provided parameters

    $args_has_run = $true
}
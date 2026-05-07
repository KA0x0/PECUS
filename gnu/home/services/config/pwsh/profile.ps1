Import-Module

$POWERSHELL_TELEMETRY_OPTOUT = true

function prompt {
    $red = [\e[31m]
    $green = [\e[32m]
    $blue = [\e[34m]
    $resetColor = [\e[0m]
    $flashing = [\e[0;5m]

    $colorUser = if ($IsAdmin) {$red else $green}
    $currentWorkingDirectory = $PWD.Path.Replace($HOME, "~")
    $host.UI.RawUI.WindowTitle = $currentWorkingDirectory
    # TODO : Auto expand aliases on return.
    return "$colorUser$env:USERNAME$resetColor@$blue$env:COMPUTERNAME:$resetColor$currentWorkingDirectory$flashing>_$resetColor"
}

Update-Help # TODO : Move to a user guix cron service, the same as user guix pull?

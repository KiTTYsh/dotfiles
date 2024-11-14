# Shortcut to edit the hosts file
function hosts {
        Start-Process "notepad.exe" -Args "C:\Windows\system32\drivers\etc\hosts" -Verb runAs
}
# Set alias to vim to bypass batch file launcher, allows UNC editing
Set-Alias -Name vim -Value 'C:\Program Files\Vim\vim91\vim.exe'

# Debauchery to make Enter-PSSession do what I want it to do
$ETSN_MD = New-Object System.Management.Automation.CommandMetaData (Get-Command Microsoft.PowerShell.Core\Enter-PSSession)
$ETSN_MD.DefaultParameterSetName = "SSHHost"
"function Enter-PSSession { " + [System.Management.Automation.ProxyCommand]::Create($ETSN_MD) + " }" | Invoke-Expression
Remove-Variable ETSN_MD

Invoke-Expression (&starship init powershell)

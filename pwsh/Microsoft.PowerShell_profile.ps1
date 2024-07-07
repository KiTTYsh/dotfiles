# Automatically install oh-my-posh
if (-not (Test-Path "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe")) {
  Set-ExecutionPolicy Bypass -Scope Process -Force
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") # https://stackoverflow.com/a/31845512
  $env:POSH_INSTALLER = "manual"
  $env:POSH_THEMES_PATH = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes"
}

# oh-my-posh initialization
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/agnoster.minimal.omp.json" | Invoke-Expression

# Shortcut to edit the hosts file
function hosts {
        Start-Process "notepad.exe" -Args "C:\Windows\system32\drivers\etc\hosts" -Verb runAs
}

# Update Oh-My-Posh
function Update-OhMyPosh {
	Set-ExecutionPolicy Bypass -Scope Process -Force
	Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
}

# Set alias to vim to bypass batch file launcher, allows UNC editing
Set-Alias -Name vim -Value 'C:\Program Files\Vim\vim91\vim.exe'

# Debauchery to make Enter-PSSession do what I want it to do
$ETSN_MD = New-Object System.Management.Automation.CommandMetaData (Get-Command Microsoft.PowerShell.Core\Enter-PSSession)
$ETSN_MD.DefaultParameterSetName = "SSHHost"
"function Enter-PSSession { " + [System.Management.Automation.ProxyCommand]::Create($ETSN_MD) + " }" | Invoke-Expression
Remove-Variable ETSN_MD

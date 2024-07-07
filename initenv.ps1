# Ensure that WinGet PS Module is available
if (!(Get-Module -ListAvailable -Name Microsoft.WinGet.Client)) {
	Write-Host "Installing PS Module Microsoft.WinGet.Client"
	Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
	Install-Module -Name Microsoft.WinGet.Client -Repository "PSGallery"
}

# Install PowerShell Core
if (!(Get-WinGetPackage -Source "winget" -MatchOption "Equals" -Id "Microsoft.PowerShell")) {
	Write-Host "Installing PowerShell Core"
	Install-WinGetPackage -Source "winget" -MatchOption "Equals" -Id "Microsoft.PowerShell" -Override "/passive ENABLE_PSREMOTING=1 ADD_PATH=1"
}

# Install vim
if (!(Get-WinGetPackage -Source "winget" -MatchOption "Equals" -Id "vim.vim")) {
	Write-Host "Installing vim"
	# Vim configuration during install uses options set in registry from last reinstall
	# Create registry key if it doesn't already exist
	if (-not (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.1')) {
		New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.1' -Force | Out-Null
	}
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Name AllowSilent -Value 1 -PropertyType DWORD -Force | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Name select_batch -Value 1 -PropertyType DWORD -Force | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Name select_console -Value 1 -PropertyType DWORD -Force | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Name select_desktop -Value 0 -PropertyType DWORD -Force | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Name select_editwith -Value 1 -PropertyType DWORD -Force | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Name select_nls -Value 1 -PropertyType DWORD -Force | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Name select_pluginhome -Value 1 -PropertyType DWORD -Force | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Name select_pluginvim -Value 0 -PropertyType DWORD -Force | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Name select_startmenu -Value 1 -PropertyType DWORD -Force | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Name select_vimrc -Value 1 -PropertyType DWORD -Force | Out-Null
	Install-WinGetPackage -Source "winget" -MatchOption "Equals" -Id "vim.vim"
}

# Install git
if (!(Get-WinGetPackage -Source "winget" -MatchOption "Equals" -Id "Git.Git")) {
	Write-Host "Installing Git"
	Install-WinGetPackage -Source "winget" -MatchOption "Equals" -Id "Git.Git"
	& 'C:\Program Files\Git\cmd\git.exe' config --global core.autocrlf false
}

# sshd
if (-not (Get-WindowsCapability -Online | Where-Object Name -EQ "OpenSSH.Server~~~~0.0.1.0" | Where-Object State -EQ "Installed")) {
  echo "Installing sshd"
  # Install sshd
  Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
  # Configure sshd
  Out-File -FilePath "C:\ProgramData\ssh\sshd_config" -InputObject "PubkeyAuthentication`tyes","AuthorizedKeysFile`t.ssh/authorized_keys","Subsystem`tsftp`tsftp-server.exe","Subsystem`tpowershell`tC:/progra~1/powershell/7/pwsh.exe -sshs -nologo" -Encoding UTF8
  # Start and enable sshd
  Start-Service sshd
  Set-Service -Name sshd -StartupType 'Automatic'
  # Configure default shell to powershell 7
  New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String -Force
}

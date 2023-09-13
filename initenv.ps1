# Get installed applications so that we can identify what needs to be installed
$InstalledApplications = Get-WmiObject -Class Win32_Product

# PowerShell 7
if (-not ($InstalledApplications | where Name -EQ "PowerShell 7-x64")) {
  echo "Installing PowerShell 7"
  cd "$env:USERPROFILE\Downloads"
  Invoke-WebRequest -Uri 'https://github.com/PowerShell/PowerShell/releases/download/v7.3.6/PowerShell-7.3.6-win-x64.msi' -OutFile powershell.msi
  msiexec.exe /package powershell.msi /quiet ENABLE_PSREMOTING=1 ADD_PATH=1
}

# Vim90
if (-not (Test-Path 'C:\Program Files\Vim\vim90\vim.exe')) {
  echo "Installing Vim90"
  
  # Create registry key if it doesn't already exist
  if (-not (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0')) {
    New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim 9.0' -Force | Out-Null
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
  cd "$env:USERPROFILE\Downloads"
  Invoke-WebRequest -Uri 'https://github.com/vim/vim-win32-installer/releases/download/v9.0.1882/gvim_9.0.1882_x64_signed.exe' -OutFile gvim.exe
  .\gvim.exe /S | Out-Null
  rm gvim.exe
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

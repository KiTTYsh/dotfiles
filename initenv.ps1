# Get installed applications so that we can identify what needs to be installed
$InstalledApplications = Get-WmiObject -Class Win32_Product

# PowerShell 7
if (-not ($InstalledApplications | where Name -EQ "PowerShell 7-x64")) {
  echo "Install PowerShell pls"
}

# Vim90
if (-not (Test-Path 'C:\Program Files\Vim\vim90\vim.exe')) {
  
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
  echo "Installing Vim90"
  .\gvim.exe /S | Out-Null
}

# sshd
if (-not (Get-WindowsCapability -Online | Where-Object Name -EQ "OpenSSH.Server~~~~0.0.1.0" | Where-Object State -EQ "Installed")) {
  Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
}

Write-Host "** Starting  Bootstrap Script **"

# Install 7-Zip and Chocolatey
Write-Host "Installing Chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Write-Host "Installing 7-Zip"
choco install 7zip.install --yes --requirechecksum
Write-Host "Enabling Remote Desktop"
netsh advfirewall firewall add rule name="RDP 3389" dir=in action=allow protocol=TCP localport=3389
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

Write-Host "** End Bootstrap **"

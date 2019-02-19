Write-Host "** Starting Virtual Box Additions Installation **"

# Virtualbox Additions Install
if ($env:PACKER_BUILDER_TYPE -eq 'virtualbox-iso') {
    Write-Host "VirtualBox Identified"
    Write-Host "Installing GuestAdditions for Windows"
    Mount-DiskImage -ImagePath $env:USERPROFILE\VBoxGuestAdditions.iso
    $ISODriveLetter = ((Get-Volume | Where-Object {$_.FileSystemLabel -like "*VBox_GAs*"}).DriveLetter)
    & $ISODriveLetter':\cert\VBoxCertUtil.exe' add-trusted-publisher $ISODriveLetter':\cert\vbox*.cer' --root $ISODriveLetter':\cert\vbox*.cer'
    & $ISODriveLetter':\VBoxWindowsAdditions.exe' /S
    Write-Host "Sleeping for 2 minutes while Virtual Box Additions are installed..."
    Start-Sleep -Seconds 120 
}

Write-Host "** Ending Virtual Box Additions Installation **"
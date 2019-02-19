Write-Host "** Starting Compression Script **"
# Clean Temp Files
Write-Host "Cleaning Temp Files"
try {
  Takeown /d Y /R /f "C:\Windows\Temp\*"
  Icacls "C:\Windows\Temp\*" /GRANT:r administrators:F /T /c /q  2>&1
  Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
}
catch { }

Write-Host "Starting DISM to clean and reduce component store..."
dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

Write-Host "Optimizing OS Drive"
Optimize-Volume -DriveLetter C

<# 
The below code will help reduce the size of the image. 
Thanks to http://blog.whatsupduck.net/2012/03/powershell-alternative-to-sdelete.html for this ingenius alternative to SDelete 
Converted WMI to CIMInstance and use LogicalDisk instead of Win32_Volume
#> 
Write-Host "Wiping empty space on disk..."
$FilePath = "C:\ThinSAN.tmp"
$Volume = Get-CimInstance Win32_LogicalDisk -Filter "DeviceId='C:'"
$ArraySize = 64kb
$SpaceToLeave = $Volume.Size * 0.05
$FileSize = $Volume.FreeSpace - $SpacetoLeave
$ZeroArray = New-Object byte[]($ArraySize)

$Stream= [io.File]::OpenWrite($FilePath)
try {
   $CurFileSize = 0
    while($CurFileSize -lt $FileSize) {
        $Stream.Write($ZeroArray,0, $ZeroArray.Length)
        $CurFileSize += $ZeroArray.Length
    }
}
finally {
    if($Stream) {
        $Stream.Close()
    }
}

Remove-Item $FilePath
Write-Host "** Ending Compression Script **"

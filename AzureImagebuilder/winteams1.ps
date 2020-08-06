# Silently install Microsoft Teams with PowerShell Script.
# Download Microsoft Teams from https://teams.microsoft.com/downloads
# This script to install Microsoft Teams 64 bits if you want 32 bits you need to change on line 19, 20 & 27 to path of Teams 32 bits
# $source = "https://statics.teams.microsoft.com/production-windows-x64/1.1.00.29068/Teams_windows.exe"
# $destination = "$Installdir\Teams_windows.exe"
# Start-Process -FilePath "$Installdir\Teams_windows.exe" -ArgumentList "-s"


# Check if Software is installed already in registry.
$CheckTeamsReg = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -like "Microsoft Teams*"}

# If Microsoft Teams is not installed continue with script. If it's istalled already script will exit.
If ($CheckTeamsReg -eq $null) {

$Installdir = "c:\buildArtifacts"    #path to download Microsoft Teams
New-Item -Path $Installdir -ItemType directory

# Download the installer from the Microsoft website. Check URL because it can be changed for new versions
$source = "https://statics.teams.microsoft.com/production-windows-x64/1.1.00.29068/Teams_windows_x64.exe"
$destination = "$Installdir\Teams_windows_x64.exe"
Invoke-WebRequest $source -OutFile $destination

# Wait for the installation to finish. Here it is 15 min. to take enough time until source of Microsoft Teams download from internet
Start-Sleep -s 1800

# Start the installation of Microsoft Teams
Start-Process -FilePath "$Installdir\Teams_windows_x64.exe"

}

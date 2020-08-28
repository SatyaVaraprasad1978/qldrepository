#Script to setup golden image with Azure Image Builder


#Create temp folder
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null


#Install VSCode
#Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?Linkid=852157' -OutFile 'c:\temp\VScode.exe'
#Invoke-Expression -Command 'c:\temp\VScode.exe /verysilent'

#Start sleep
#Start-Sleep -Seconds 10

#InstallNotepadplusplus
#Invoke-WebRequest -Uri 'https://notepad-plus-plus.org/repository/7.x/7.7.1/npp.7.7.1.Installer.x64.exe' -OutFile 'c:\temp\notepadplusplus.exe'
#Invoke-Expression -Command 'c:\temp\notepadplusplus.exe /S'

#Start sleep
Start-Sleep -Seconds 10

#InstallFSLogix
#Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
#Start-Sleep -Seconds 10
#Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
#Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'

#Start sleep
#Start-Sleep -Seconds 10

#InstallTeamsMachinemode
New-Item -Path 'HKLM:\SOFTWARE\Citrix\PortICA' -Force | Out-Null
Invoke-WebRequest -Uri 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&download=true&managedInstaller=true&arch=x64' -OutFile 'c:\temp\Teams.msi'
Invoke-Expression -Command 'msiexec /i C:\temp\Teams.msi /quiet /l*v C:\temp\teamsinstall.log ALLUSER=1'
Start-Sleep -Seconds 30
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32 -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force


#==========================================================================
# INSTALLING AND CONFIGURING CITRIX WORKSPACE APP FOR WINDOWS
#
# Author: Citrix Systems, Inc.
# Date  : 16.03.2020
# Editor: Microsoft Visual Studio Code
# Citrix Workspace app versions supported by this script: ALL
# https://docs.citrix.com/en-us/tech-zone/build/tech-papers/citrix-workspace-app.html
#==========================================================================

# Error handling
$global:ErrorActionPreference = "Stop"
if($verbose){ $global:VerbosePreference = "Continue" }

# Disable File Security (prevents the "Open File – Security Warning" dialog -> "Do you want to run this file")
$env:SEE_MASK_NOZONECHECKS = 1

# Custom variables [edit | customize to your needs]
$LogDir = "C:\Logs\Citrix Workspace app"                                       # the full path to your log directory
$LogFile = Join-Path $LogDir "Install Citrix Workspace app.log"                # the full path to your log file
$StartDir = "c:\temp\CitrixWorkspaceApp.exe"                                                      # the directory path of the installation file(s). $PSScriptRoot is the directory of the current script.
$InstallFileName = "CitrixWorkspaceApp.exe"                                    # the name of the installation file. Options: 'CitrixWorkspaceApp.exe' or 'CitrixWorkspaceAppWeb.exe'.
$InstallArguments = "/silent /includeSSON /FORCE_LAA=1"                        # the command line arguments for the installation file
$ClientSelectiveTrustRegKeys = "CitrixWorkspaceApp_Client_Selective_Trust.reg" # the name of the registry file containing the Client Selective Trust settings

# Create the log directory if it does not exist
if (!(Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType directory | Out-Null }

# Function WriteToLog
Function WriteToLog {
    param(
        [string]$InformationType,
        [string]$Text
    )

    $DateTime = (Get-Date -format dd-MM-yyyy) + " " + (Get-Date -format HH:mm:ss)
    if ( $Text -eq "" ) {
        Add-Content $LogFile -value ("")   # Write an empty line
    } else {
        Add-Content $LogFile -value ($DateTime + " " + $InformationType.ToUpper() + " - " + $Text)
    }
}  

# Create a new log file (overwriting any existing one)
New-Item -Path $LogFile -ItemType "file" -force | Out-Null

# Write to log file
WriteToLog "I" "Install Citrix Workspace app" $LogFile
WriteToLog "I" "----------------------------" $LogFile
WriteToLog "-" "" $LogFile

############################
# Pre-Installation         #
############################

# Cleanup: delete existing group policy registry keys (reference: https://docs.citrix.com/en-us/citrix-workspace-app-for-windows/install.html#uninstall)
WriteToLog "I" "Cleanup: delete existing Citrix Workspace group policy registry keys" $LogFile
$x = 0
try {
    $RegKeyPath = "hklm:\SOFTWARE\Policies\Citrix\ICA Client"
    if ( Test-Path $RegKeyPath ) {
        $x++
        Remove-Item -Path $RegKeyPath -recurse
    }
    $RegKeyPath = "hklm:\SOFTWARE\Wow6432Node\Policies\Citrix\ICA Client"
    if ( Test-Path $RegKeyPath ) {
        $x++
        Remove-Item -Path $RegKeyPath -recurse
    }
    if ( $x -eq 0 ) {
        WriteToLog "I" "No existing group policy registry keys were found. Nothing to do." $LogFile
    } else {
        WriteToLog "S" "The group policy registry keys were deleted successfully" $LogFile
    }
} catch {
    WriteToLog "E" "An error occurred trying to delete the group policy registry keys (error: $($Error[0]))" $LogFile
    Exit 1
}

# Write an empty line to the log file
WriteToLog "-" "" $LogFile

# Cleanup: delete old Citrix Workspace app log folders in the TEMP directory
WriteToLog "I" "Cleanup: delete old Citrix Workspace app log folders" $LogFile
try {
    Get-ChildItem -path ( Join-Path $env:Temp "CTXReceiverInstallLogs*" ) -directory | Remove-Item -force -recurse
    WriteToLog "S" "The old log folders were deleted successfully (or they did not exist in the first place)" $LogFile
} catch {
    WriteToLog "E" "An error occurred trying to delete the old log folders (error: $($Error[0]))" $LogFile
    Exit 1
}

# Write an empty line to the log file
WriteToLog "-" "" $LogFile

############################
# Installation             #
############################
Invoke-WebRequest -Uri 'https://downloadplugins.citrix.com/Windows/CitrixWorkspaceApp.exe' -OutFile 'c:\temp\CitrixWorkspaceApp.exe'
$InstallFile = Join-Path $StartDir $InstallFileName
WriteToLog "I" "Install Citrix Workspace app" $LogFile
WriteToLog "I" "Command: $InstallFile $InstallArguments" $LogFile
if ( Test-Path $InstallFile ) {
    $Process = Start-Process -FilePath $InstallFile -ArgumentList $InstallArguments -PassThru -ErrorAction Stop
    Wait-Process -InputObject $process
    switch ($Process.ExitCode) {
        0 { WriteToLog "S" "Citrix Workspace app was installed successfully (exit code: 0)" $LogFile }
        3 { WriteToLog "S" "Citrix Workspace app was installed successfully (exit code: 3)" $LogFile } # Some Citrix products exit with 3 instead of 0
        1603 {
            WriteToLog "E" "A fatal error occurred (exit code: 1603). Some applications throw this error when the software is already (correctly) installed! Please check the log files!" $LogFile
            Exit 1
            }
        1605 {
            WriteToLog "E" "Citrix Workspace app is not currently installed on this machine (exit code: 1605)" $LogFile
            Exit 1
            }
        1619 {
            WriteToLog "E" "The installation files cannot be found. The PS1 script should be in the root directory and all source files in the subdirectory 'Files' (exit code: 1619)" $LogFile
            Exit 1
            }
        3010 { WriteToLog "W" "A reboot is required (exit code: 3010)!" $LogFile }
        40008 {
            WriteToLog "I" "This version of Citrix Workspace app has already been installed. Nothing to do!" $LogFile
            # Re-enable File Security
            Remove-Item env:\SEE_MASK_NOZONECHECKS

            # Write an empty line to the log file
            WriteToLog "-" "" $LogFile
            WriteToLog "I" "End of script" $LogFile
            Exit 0
        }
        default {
            WriteToLog "E" "The installation ended in an error (exit code: $($Process.ExitCode))" $LogFile
            Exit 1
        }
    }
} else {
    WriteToLog "E" "The file '$InstallFile' could not be found" $LogFile
    Exit 1
}

# Write an empty line to the log file
WriteToLog "-" "" $LogFile

############################
# Post-Installation        #
############################

# Optional: import the Client Selective Trust registry keys and values. This prevents security popup messages regarding permissions for access to files, microphones, cameras, scanners, etc. in the local intranet and trusted sites.
# Reference: How to Configure Default Device Access Behavior of Receiver, XenDesktop and XenApp (https://support.citrix.com/article/CTX133565)
$RegFile = Join-Path $StartDir $ClientSelectiveTrustRegKeys
WriteToLog "I" "Optional: import the Client Selective Trust registry keys and values. This prevents security popup messages during logon" $LogFile
WriteToLog "I" "Import registry file '$RegFile'" $LogFile
if ( Test-Path $RegFile ) {
    try {
        $process = start-process -FilePath "reg.exe" -ArgumentList "IMPORT ""$RegFile""" -WindowStyle Hidden -Wait -PassThru
        if ( $process.ExitCode -eq 0 ) {
            WriteToLog "S" "The registry settings were imported successfully (exit code: $($process.ExitCode))" $LogFile
        } else {
            WriteToLog "E" "An error occurred trying to import registry settings (exit code: $($process.ExitCode))" $LogFile
            Exit 1
        }
    } catch {
        WriteToLog "E" "An error occurred trying to import the registry file '$RegFile' (error: $($Error[0]))!" $LogFile
        Exit 1
    }
} else {
    WriteToLog "I" "The file '$RegFile' could not be found. Nothing to do." $LogFile
}

# Write an empty line to the log file
WriteToLog "-" "" $LogFile

# Copy the Citrix Workspace app log files to the custom log path defined in the variable '$LogDir'
WriteToLog "I" "Copy the log files from the TEMP directory to '$LogDir'" $LogFile
$CitrixLogPath = (Get-ChildItem -directory -path $env:Temp -filter "CTXReceiverInstallLogs*").FullName
if ( Test-Path ( $CitrixLogPath + "\*.log" ) ) {
    $SourceFiles = Join-Path $CitrixLogPath "*.log"
    WriteToLog "I" "Source files          = $SourceFiles" $LogFile
    WriteToLog "I" "Destination directory = $LogDir" $LogFile
    try {
        Copy-Item $SourceFiles -Destination $LogDir -Force -Recurse
        WriteToLog "S" "The log files were copied successfully" $LogFile
    } catch {
        WriteToLog "E" "An error occurred trying to copy the log files" $LogFile
        Exit 1
    }
} else {
    WriteToLog "I" "There are no log files in the directory '$CitrixLogPath'. Nothing to copy." $LogFile
}

# Re-enable File Security
Remove-Item env:\SEE_MASK_NOZONECHECKS

# Write an empty line to the log file
WriteToLog "-" "" $LogFile
WriteToLog "I" "End of script" $LogFile

#           Bitpusher
#            \`._,'/
#            (_- -_)
#              \o/
#          The Digital
#              Fox
#          @VinceVulpes
#    https://theTechRelay.com
# https://github.com/bitpusher2k
#
# TEMPLATE_simple.ps1 - By Bitpusher/The Digital Fox
# v1.0 last updated 2025-00-00
# Script to XXXX
#
# Usage:
# powershell -executionpolicy bypass -f ./TEMPLATE.ps1 -Parameter "value"
#
# A set of basic templates for BAT/PS scripts to facilitate good practices
# when scripting for scheduled tasks and automation across many endpoints.
# When running scripts in a way that the execution is not being monitored
# there are several factors which become much more important:
#
# 1. Documentation - Standardized information and instructions at
#      the beginning of the script (name, version, date, how to).
# 2. Logging - Central log location & basic log management. Including of
#      endpoint name in log name. Option to email log file or copy to
#      shared folder. Uses PS transcript for accuracy and verbosity of log.
# 3. Date stamps - Date stamps included in log name and in the log files
#      themselves, including ISO8601-formatted version.
# 4. Process priority - Includes option to set script priority
#      (for scripts that are resource intensive).
# 5. Timing of execution - Includes option to add random delay to script
#      execution (for staggering execution when running across many endpoints).
# 6. Error handling - Catches basic errors, and set up to return exit status.
#
# To undo: XXXX
#
# Run with admin privileges
#
# email log to yourself by including the emailServer, emailFrom, emailTo
# emailUsername, and emailPassword parameters.
# email using Mailozaurr using emailServer, emailFrom, emailTo, emailUsername,
# emailPassword parameters and setting Mailozaurr to "1".
# email using Mailozaurr through M$ Graph using emailFrom, emailTo, 
# ClientID, ClientSecret, DirectoryID parameters and setting Mailozaurr to "1".
#
# when creating a scheduled task to run such scripts, use the following structure example:
# powershell.exe -NoProfile -ExecutionPolicy Bypass -Scope Process -File "C:\Utility\TEMPLATE.ps1"
#
# To run as a scheduled task start PowerShell:
# C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe
# With arguments something like this:
# -Command "& 'C:\Utility\TEMPLATE.ps1' -Param1 XXX1,XXX2,XXX3 -Param2 15"
#
# To run remotely on a list of endpoints with PS remoting already enabled (Enable-PSRemoting):
# Invoke-Command -FilePath "C:\Utility\TEMPLATE.ps1" -ComputerName endpoint1,endpoint2,endpoint3
# or
# Invoke-command -ComputerName (get-content c:\Utility\EndpointList.txt) -filepath c:\Utility\TEMPLATE.ps1
# or using PsExec:
# psexec -s \\endpoint1 Powershell -ExecutionPolicy Bypass -File \\dc\netlogon\scripts\TEMPLATE.ps1
#
#template #script #powershell

#Requires -Version 5.1

param(
    [Parameter(Mandatory = $true)]
    [string]$CustomParameter = "defaultvalue",
    [string]$scriptName = "TEMPLATE_CHANGE_ME",
    [string]$Priority = "Normal",
    [int]$RandMax = "500",
    [string]$DebugPreference = "SilentlyContinue",
    [string]$VerbosePreference = "SilentlyContinue",
    [string]$InformationPreference = "Continue",
    [string]$logFileFolderPath = "C:\Utility\log",
    [string]$ComputerName = $env:computername,
    [string]$ScriptUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
    [string]$emailServer = "",
    [string]$emailPort = "587",
    [string]$emailFrom = "",
    [string]$emailTo = "",
    [string]$emailUsername = "",
    [string]$emailPassword = "",
    [string]$Mailozaurr = "0",
    [string]$Graph = "0",
    [string]$ClientID = "",
    [string]$DirectoryID = "",
    [string]$ClientSecret = "",
    [string]$shareLocation = "",
    [string]$shareUsername = "",
    [string]$sharePassword = "",
    [string]$logFilePrefix = "$scriptName" + "_" + "$ComputerName" + "_",
    [string]$logFileDateFormat = "yyyyMMdd_HHmmss",
    [int]$logFileRetentionDays = 30,
    [string]$Encoding = "utf8bom" # PS 5 & 7: "Ascii" (7-bit), "BigEndianUnicode" (UTF-16 big-endian), "BigEndianUTF32", "Oem", "Unicode" (UTF-16 little-endian), "UTF32" (little-endian), "UTF7", "UTF8" (PS 5: BOM, PS 7: NO BOM). PS 7: "ansi", "utf8BOM", "utf8NoBOM"
)

Process {
    #region initialization
    if ($PSVersionTable.PSVersion.Major -eq 5 -and ($Encoding -eq "utf8bom" -or $Encoding -eq "utf8nobom")) { $Encoding = "utf8" }

    function Get-TimeStamp {
        param(
            [switch]$NoWrap,
            [switch]$Utc
        )
        $dt = Get-Date
        if ($Utc -eq $true) {
            $dt = $dt.ToUniversalTime()
        }
        $str = "{0:yyyy-MM-dd} {0:HH:mm:ss}" -f $dt

        if ($NoWrap -ne $true) {
            $str = "[$str]"
        }
        return $str
    }

    function Test-FileLock {
        param(
            [Parameter(Mandatory = $true)] [string]$Path
        )

        $oFile = New-Object System.IO.FileInfo $Path

        if ((Test-Path -Path $Path) -eq $false) {
            return $false
        }

        try {
            $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)

            if ($oStream) {
                $oStream.Close()
            }
            return $false
        } catch {
            # file is locked by a process.
            return $true
        }
    }

    if ($logFileFolderPath -ne "") {
        if (!(Test-Path -PathType Container -Path $logFileFolderPath)) {
            Write-Output "$(Get-TimeStamp) Creating directory $logFileFolderPath" | Out-Null
            New-Item -ItemType Directory -Force -Path $logFileFolderPath | Out-Null
        } else {
            $DatetoDelete = $(Get-Date).AddDays(- $logFileRetentionDays)
            Get-ChildItem $logFileFolderPath | Where-Object { $_.Name -like "*$logFilePrefix*" -and $_.LastWriteTime -lt $DatetoDelete } | Remove-Item | Out-Null
        }
        $logFilePath = $logFileFolderPath + "\$logFilePrefix" + (Get-Date -Format $logFileDateFormat) + ".LOG"
    }

    # Set script priority
    # Possible values: Idle, BelowNormal, Normal, AboveNormal, High, RealTime
    $process = Get-Process -Id $pid
    Write-Output "Setting process priority to `"$Priority`""
    #Write-Output "Script priority before:"
    #Write-Output $process.PriorityClass
    $process.PriorityClass = $Priority
    #Write-Output "Script priority After:"
    #Write-Output $process.PriorityClass
    #endregion initialization

    #region main
    # debug tracing - set to "2" for testing, set to "0" for production use
    Set-PSDebug -Trace 2
    [int]$MyExitStatus = 1
    $StartTime = $(Get-Date)
    Write-Output "Script $scriptName started at $(Get-TimeStamp)" | Tee-Object -FilePath $logFilePath -Append
    Write-Output "ISO8601:$(Get-Date (Get-Date).ToUniversalTime() -UFormat '+%Y%m%dT%H%M%S.000Z')`n" | Tee-Object -FilePath $logFilePath -Append
    $RandSeconds = Get-Random -Minimum 1 -Maximum $RandMax
    Write-Output "Waiting $RandSeconds seconds (between 1 and $RandMax) to stagger execution across devices`n" | Tee-Object -FilePath $logFilePath -Append
    Start-Sleep -Seconds $RandSeconds

    #
    # Start main script body
    # NOTE: This template does not turn on transcription, and if nothing is explicitly written to the log at $logFilePath, it will be empty
    # TODO: Replace this block with your actual script body:
    #
    if ($logFileFolderPath -ne "") {
        $TmpFile = $logFileFolderPath + "\$scriptName" + ".TMP"
    } else {
        $TmpFile = "C:\temp\output.TMP"
    }
    Write-Output "$(Get-TimeStamp) Example output message."
    #
    # End main script body
    # Remember to update $scriptName parameter
    #

    $MyExitStatus = 0
    #endregion main

    #region finalization
    if ($logFileFolderPath -ne "") {
        Write-Output "`nScript $scriptName ended at $(Get-TimeStamp)" | Tee-Object -FilePath $logFilePath -Append
        $elapsedTime = $(Get-Date) - $StartTime
        Write-Output "Elapsed time (seconds): $($elapsedTime.TotalSeconds)" | Tee-Object -FilePath $logFilePath -Append
        Write-Output "ISO8601:$(Get-Date (Get-Date).ToUniversalTime() -UFormat '+%Y%m%dT%H%M%S.000Z')`n" | Out-File -FilePath $logFilePath -Append
        if (($emailFrom -ne "") -and ($emailTo -ne "")) {
            if ($Mailozaurr -eq "1") {
                if (!Get-Module -Name Mailozaurr) { Install-Module -Name Mailozaurr -AllowClobber -Force }
                if ($Graph -eq "1") {
                    $Credential = ConvertTo-GraphCredential -ClientID $ClientID -ClientSecret $ClientSecret -DirectoryID $DirectoryID
                    Send-EmailMessage -From "$emailFrom" -To "$emailTo" -Subject "$scriptName - $ComputerName - $MyExitStatus - Log File" -Text "$logFilePath" -UseSsl -Credential $Credential -Graph -Verbose -Priority Low -DoNotSaveToSentItems -Attachment @("$logFilePath")
                } else {
                    Send-EmailMessage -Server "$emailServer" -Port $emailPort -From "$emailFrom" -To "$emailTo" -Subject "$scriptName - $ComputerName - $MyExitStatus - Log File" -Text "$logFilePath" -UseSsl -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$emailUsername", (ConvertTo-SecureString -String "$emailPassword" -AsPlainText -Force)) -Attachment $logFilePath
                }
            } else {
                Send-MailMessage -SmtpServer "$emailServer" -Port $emailPort -From "$emailFrom" -To "$emailTo" -Subject "$scriptName - $ComputerName - $MyExitStatus - Log File" -Body "$logFilePath" -UseSsl -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$emailUsername", (ConvertTo-SecureString -String "$emailPassword" -AsPlainText -Force)) -Attachments $logFilePath
            }
        }
        if (($shareLocation -ne "") -and ($shareUsername -ne "") -and ($sharePassword -ne "")) {
            [securestring]$secStringPassword = ConvertTo-SecureString $sharePassword -AsPlainText -Force
            [pscredential]$shareCred = New-Object System.Management.Automation.PSCredential ($shareUsername, $secStringPassword)
            New-PSDrive -Name LogStore -PSProvider FileSystem -Root "$shareLocation" -Description "Log Store" -Credential $shareCred
            $destFolder = "LogStore:\"
            Copy-Item -LiteralPath "$logFilePath" -Destination "$destFolder" -Force -ErrorAction Continue -ErrorVariable ErrorOutput
            Remove-PSDrive -Name LogStore
        }
    }
    Set-PSDebug -Trace 0
    #Get-Content $logFilePath
    exit $MyExitStatus
    #endregion finalization
}

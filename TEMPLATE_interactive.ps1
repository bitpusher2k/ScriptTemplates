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
# Template_interactive.ps1 - By Bitpusher/The Digital Fox
# v1.5 last updated 2024-01-24
# Script to XXXXXXXXX
#
# Usage:
# powershell -executionpolicy bypass -f ./XXXXXXXXXX.ps1
#
# Super basic template for use in interactive scripts.
# Does not include the logging and reporting
# of the other templates meant to be run remotely or scheduled.
#
# Uses: Template
#
#comp #script #powershell

#Requires -Version 5.1

param(
    [string]$Parameter,
    [string]$OutputPath,
    [string]$Encoding = "utf8bom" # "ascii","ansi","bigendianunicode","unicode","utf8","utf8","utf8NoBOM","utf32"
)

if ($PSVersionTable.PSVersion.Major -eq 5 -and ($Encoding -eq "utf8bom" -or $Encoding -eq "utf8nobom")) { $Encoding = "utf8" }

$date = Get-Date -Format "yyyyMMddHHmmss"

## If OutputPath variable is not defined, prompt for it
if (!$OutputPath) {
    Write-Output ""
    $OutputPath = Read-Host "Enter the output base path, e.g. $($env:userprofile)\Desktop\Output (default)"
    if ($OutputPath -eq '') { $OutputPath = "$($env:userprofile)\Desktop\Output" }
    Write-Output "Output base path will be in $OutputPath"
}

## If OutputPath does not exist, create it
$CheckOutputPath = Get-Item $OutputPath -ErrorAction SilentlyContinue
if (!$CheckOutputPath) {
    Write-Output ""
    Write-Output "Output path does not exist. Directory will be created." -ForegroundColor Yellow
    mkdir $OutputPath
}



## Do Stuff....
Write-Output "..."
$var = "this,is,a,variable"
$OutputCSV = "$OutputPath\FileName.csv"
$var | Export-Csv -Path $OutputCSV -NoTypeInformation -Append -Encoding $Encoding



if ((Test-Path -Path $OutputCSV) -eq "True") {
    Write-Output `n" The Output file is available at:"
    Write-Output $OutputCSV
    $Prompt = New-Object -ComObject wscript.shell
    $UserInput = $Prompt.popup("Do you want to open output file?", 0, "Open Output File", 4)
    if ($UserInput -eq 6) {
        Invoke-Item "$OutputCSV"
    }
}

Write-Output "`nDone! Check output path for results."
Invoke-Item "$OutputPath"

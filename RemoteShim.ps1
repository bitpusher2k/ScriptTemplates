# Some fragments related to testing & using remote PS execution
#
# Will flesh out into full shim as needed.
#
# https://learn.microsoft.com/en-us/powershell/scripting/learn/remoting/running-remote-commands?view=powershell-7.4
# https://lazyadmin.nl/powershell/invoke-command/

#powershell #remote #shim #script

# Get remote system information:
$comp = Read-Host "Remote computer"
$usr = Read-Host "Username"
$passwd = Read-Host "Password" -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential ($usr, $passwd)

if (Test-Connection -ComputerName $comp -Quiet -and Test-WSMan -Computername $comp) {
    Write-Output "Able to connect and remotely run commands on $comp. Continuing..."
    $scriptArray = @()
    $LocalHereScript = @'
# script code here
$var = "Hello local World!"
Write-Output "$var"
$var | Out-File -Filepath "c:\temp\testfile.txt" -append
'@
    $scriptArray += $LocalHereScript
    $scriptArray[0] | Out-File SubScript.ps1

    Invoke-Command -ComputerName $comp -Credential $cred -ScriptBlock { param($proc, $proc2) Get-Process -Name $proc, $proc2 } -ArgumentList "Notepad", "Calc"
    Invoke-Command -ComputerName $comp -Credential $cred -FilePath RemoteHereScript.ps1
    invoke-Command -ComputerName $comp -Credential $cred -ScriptBlock $scriptArray
    $session = New-PSSession -ComputerName $comp -Credential $cred
    Invoke-Command -Session $session -ScriptBlock { New-Item -Type file c:\temp\blah.txt } -ArgumentList "bla"
    Remove-PSSession $session
} else {
    Write-Output "Unable to remotely run commands on $comp. Attempting to enable PsRemoting..."
    psexec.exe \\$comp -s powershell Enable-PsRemoting -Force
    wmic /node:[IP] process call create "powershell enable-psremoting -force"
}

Write-Output "Done!"
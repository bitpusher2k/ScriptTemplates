# PowerShell script fragment to remotely enable PowerShell remoting using PSSession/PsExec/WMI
#
# GPO recommended for broad deployment to AD endpoints
#
# More info:
# https://adamtheautomator.com/enable-psremoting/
# https://4sysops.com/archives/enable-powershell-remoting/

#enable #ps #remoting #script #pssession #psexec #WMI #GPO


# Allow pw prompts to be entered from the console:
# $key = “HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds”
# Set-ItemProperty $key ConsolePrompting True
# Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" -Name "ConsolePrompting" -Value $True
# And to remove this ability when done:
# Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" -Name "ConsolePrompting"

# Get remote system information:
$comp = Read-Host "Remote computer"
$usr = Read-Host "Username"
$passwd = Read-Host "Password" -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential ($usr, $passwd)

# Locally enable PS Remoting:
# Get-NetConnectionProfile
# Enable-PSRemoting
# Enable-PSRemoting -Force -SkipNetworkProfileCheck # If network connection type is "public"
# If not in AD environment (in a Workgroup) ned to add TrustedHosts manually:
# Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.200" -Force

# Manually enable PS Remoting through remote PS Session:
Enter-PSSession -ComputerName $comp -Credential $cred
Enable-PSRemoting

# Enable PS Remoting through PsExec:
.\PsExec64.exe -accepteula
# reg ADD HKCU\Software\Sysinternals\PSexec /v EulaAccepted /t REG_DWORD /d 1 /f
.\PsExec64.exe \\$comp -u "$usr" -p -h -s powershell.exe Enable-PSRemoting -Force

# Enable PS Remoting through WMI:
$SessionArgs = @{
    ComputerName  = "$comp"
    Credential    = $cred # Or just Get-Credential
    SessionOption = New-CimSessionOption -Protocol Dcom
}
$MethodArgs = @{
    ClassName     = 'Win32_Process'
    MethodName    = 'Create'
    CimSession    = New-CimSession @SessionArgs
    Arguments     = @{
        CommandLine = "powershell Start-Process powershell -ArgumentList 'Enable-PSRemoting -Force'"
    }
}
Invoke-CimMethod @MethodArgs

end
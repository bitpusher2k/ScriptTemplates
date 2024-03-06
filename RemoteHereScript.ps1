# PowerShell script-within-a-script method that can be handy when running script remotely

#remote #here #script

$scriptText = @'
# script code here
$var = "Hello remote World!"
Write-Output "$var"
$var | Out-File -Filepath "c:\temp\testfile.txt" -append
'@

Write-Output "This is a test"
invoke-expression $scriptText
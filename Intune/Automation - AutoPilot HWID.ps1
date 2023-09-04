Install-Script -Name Get-WindowsAutoPilotInfo
New-Item -Type Directory -Path "C:\HWID"
Set-Location -Path "C:\HWID"
Get-WindowsAutoPilotInfo -OutputFile AutopilotHWID.csv

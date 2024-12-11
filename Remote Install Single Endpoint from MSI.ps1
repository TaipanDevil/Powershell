<#
Title: SingleEndpoint-Install.ps1
Author: Andrew Zeng
Creation Date: 2024/03/21 @4PM MDT
Rev.: 
Rev. By:
Rev. Date:

Please Note this script needs to be run in an Admin Powershell Shell to work.

This is a very basic script with no error checking.

#>

$logon = Get-Credential 
$RemotePC = "ComputerName"
$DPath = '\\' + $RemotePC +'\c$\Windows\Temp\' #path to where on the remote computer you want to dump the file
$SPath = '\\Location\Of\Your\MSI\File'

Copy-Item -Path $SPath -Destination $DPath

Invoke-Command -ComputerName $RemotePC -Credential $logon -ScriptBlock {
          
     Start-Process -FilePath msiexec.exe -ArgumentList '/i C:\Windows\Temp\NameOfMSI.msi /quiet /norestart' -Wait #stored here as windows will automatically clean these files
    #Start-Process -FilePath "C:\Windows\Temp\NameOfExE.exe" -ArgumentList "/QN" -Wait #this is untested for exe deployments
    }

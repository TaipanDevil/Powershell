<#
Title: MultiEndpoint-Install.ps1
Author: TaipanDevil
Creation Date: 2024/03/21 @4PM MDT
Rev.: 2
Rev. By: TaipanDevil
Rev. Date: 2024/04/03 @12:02PM MDT

Please Note this script needs to be run in an Admin Powershell Shell to work.
This was built off of the SingleLaptop-Install.ps1 script.

Rev1Details- Date: 2024/03/22 @10:10AM MDT -TaipanDevil
    Added this comment block

Rev2Details- Date: 2024/04/03 @12:02PM MDT -TaipanDevil
    Revamped the script to use a csv instead of going through all AD computer objects.

#>
$Comps = Import-Csv -Path "\\Path\To\List\Of\Remote\Computers.csv"
$MSIPath = '\\Location\of\your\MSI'
$logon = Get-Credential

$Comps | ForEach-Object{
    [PsCustomObject]@{
        CompName     = $RemotePC
        InstallStatus = $Status
    }
    $RemotePC = $_.name
    $Path = '\\' + $RemotePC + '\c$\Windows\Temp\'
    $Status = 
    $error.Clear()
    Try {Copy-Item -Path $LPath -Destination $Path}
    Catch {Write-Warning "$RemotePC failed the install"}
    If($error){
    $Status = "Failed"
    }
    If(!$error){
        Copy-Item -Path $MSIPath -Destination $Path
        Invoke-Command -ComputerName $RemotePC -Credential $logon -ScriptBlock {
            Start-Process -FilePath msiexec.exe -ArgumentList '/i C:\Windows\Temp\MSI.msi /quiet /norestart' -Wait
        } 
        $Status = "Successful"
        Write-Host "$RemotePC was $Status in the install"
    }
  }
} | Export-Csv -Path "\\Path\to\where\you\want\to\store\your\log\file.csv" -NoTypeInformation

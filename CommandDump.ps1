<# A test to see if finding all users in an OU and sub OUs
$OUPath = 'OU=Put,OU=OU,OU=Path,DC=Here,DC=Please'

$AllUsers = Get-ADUser -Filter * -SearchBase $OUpath -Properties * #add "-SearchScope Subtree" if you want the sub OUs as well
#>
#install MSIx package without Microsoft Store enabled. Note this will only install the application on the user profile that runs the script.
#Add-AppxPackage -Path C:\Path\App-Package.msixbundle #or App-Package.msix

<# #To check if a user is a member of a security group
$mems = Get-ADGroupMember -Identity 'Security GroupName' 
$mems | ForEach-Object{
    If ($_ -Match 'DisplayName'){
        Write-Host "Yes"
        }
}#>

#------------------------------------------------------------------------------------------------------------------------------------------------

<# #Gets the OU that the user in found in
$CU = Get-ADUser UserName -Properties * 
$COU = $CU.DistinguishedName -replace '^.*?,(?=[A-Z]{2}=)'
Write-Host "$COU"
#>
<#
$TempPath = "\\fsfilesvr-03\KrpData-H_Drv\Common Files\_Temp Work Area"
$TName = "\$(($CU.GivenName)) $(($CU.sn).Substring(0,1))"
$TFUll = '$TempPath'+ '\' + '$TName'
Write-Host "$TFULL"
Test-Path -Path "$TFULL"
#>
<#
$logname = "C:\Scripts\CSVs\Test\ReportsTest.csv"
New-Item -Path $logname
Set-Content $logname 'DisplayName, SamAccountName, Title, Department'
$CU | Select -ExpandProperty DirectReports| ForEach-Object {
    
    $DReport = Get-ADUser $_ -Properties * | Select DisplayName, SamAccountName, Title, Department | Export-Csv -Append -Path $logname -NoTypeInformation

    }
    #>
    
<# #Even I am confused why I put this in here
$G = Import-Csv -Path '\\path\to\a\csv.csv' 
$G | ForEach-Object{
    [PsCustomObject]@{
        Name     = $DName
        Group    = $($UserOU.Name)
    }#This is what is exported to the CSV

    $DName = $_.name
    $Group = $_.group


        $CU = Get-ADUser -F { DisplayName -eq $DName } -Properties *
        $COU = $CU.DistinguishedName -replace '^.*?,(?=[A-Z]{2}=)'
        $UserOU = Get-ADOrganizationalUnit -Identity $COU -Properties *
  
} | Export-Csv -Path "\\path\to\the\log\csv.csv" -NoTypeInformation
#>

#---------------------------------------------------------------------------------------------------------------------------------------------------------

<# #this was a test before I input it into a script to re-write a csv
$Org = Import-Csv '\\path\to\a\user\account\csv.csv'

$Org|ForEach-Object{
    $Name = $_.name
    $Title = $_.title
    Write-Host "$Title"
    if(("$Title").Contains(",")){
        $Title = ($Title).Replace(',' , ' -')
    }

    Write-Host "$Title"
}#>

<# #counts the log files in your folder
$i=1

Get-ChildItem -Path "\\path\to\your\log\folder" -Recurse -Force | foreach-object{If($_ -match 'LogNameHere.csv') { $i++ }}

Write-Host "$i"
#>

#-----------------------------------------------------------------------------------------------------------------------------

<#  #Check to see who is logged into a remote computer

Get-WmiObject -ComputerName 'InsertComputerNameHere' -Class Win32_ComputerSystem | Select-Object UserName

Get-CimInstance –ComputerName 'InsertComputerNameHere' –ClassName Win32_ComputerSystem | Select-Object UserName


function Get-LoggedOnUser
 {
     [CmdletBinding()]
     param
     (
         [Parameter()]
         [ValidateScript({ Test-Connection -ComputerName $_ -Quiet -Count 1 })]
         [ValidateNotNullOrEmpty()]
         [string[]]$ComputerName = $env:COMPUTERNAME
     )
     foreach ($comp in $ComputerName)
     {
         $output = @{ 'ComputerName' = $comp }
         $output.UserName = (Get-WmiObject -Class win32_computersystem -ComputerName $comp).UserName
         [PSCustomObject]$output
     }
 }

 
#>

#---------------------------------------------------------------------------------------------------------------------------------


#Check uptime for remote computer

<#

(Get-Date) - (Get-CimInstance Win32_OperatingSystem -ComputerName $computer).LastBootupTime

(Get-Date) - [Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject Win32_OperatingSystem -ComputerName $computer).LastBootUpTime)

#>


#---------------------------------------------------------------------------------------------------------------------------------


#Get serial number since wmic is being removed by microsoft

<#
Get-WmiObject win32_bios | select SerialNumber
#>

#---------------------------------------------------------------------------------------------------------------------------------

Import-Module ActiveDirectory
$TermedUsers = Import-Csv "C:\path\to\your\csv.csv"
$logon = Get-Credential
$Password = Read-Host "What is the Reset Password (No initals)?" -AsSecureString
$TermedUserPerms = 'Place Any Termed user permission groups here in an array'

Foreach($Term in $TermedUsers) {
    
    $username = $Term.username
    
    if(Get-ADUser -F { SamAccountName -eq $username }) {
    
        $User = Get-ADUser $username -Properties *
        $initals = ($User.SamAccountName).Substring(0,2)
        $LogName = "$(($User.DisplayName)) ADGroup Memberships.csv"
        $UDetailsLog = "$($User.SamAccountName) AccountDetails.csv"
        $User | Select DislpayName, Username, Title, Manager, Department, OfficePhone | Export-Csv -Path "C:\Path\to\where\you\want\your\before\changes\log\$UDetailsLog" -NoTypeInformation
       
        $User.MemberOf | ForEach-Object {
            [PsCustomObject]@{
                Name     = $(($User.DisplayName))
                Username = $(($User.SamAccountName))
                ADGroup  = $_
            }#This is what is exported to the CSV

            Remove-ADGroupMember -Identity $_ -Members $User.SamAccountName -Confirm:$False -Credential $logon
            Write-Host "$(($User.DisplayName)) has been removed from $_"
        
        } | Export-Csv -Path "\\Path\to\where\you\want\to\store\your\after\change\log\file\$LogName" -NoTypeInformation
        
        Set-ADAccountPassword -Identity $(($User.SamAccountName)) -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Password$initals" -Force) -Credential $logon
        Set-ADUser $(($User.SamAccountName)) -Description "$((Get-Date).ToString("yyyy.MM.dd")) pwd reset" -Credential $logon
        Write-Host "$(($User.DisplayName))'s passward was reset and description changed." -ForegroundColor Green

        Set-ADAccountExpiration -Identity $(($User.SamAccountName)) -DateTime "$((Get-Date).ToString("yyyy.MM.dd HH:mm:ss"))"
        Write-Host "$(($User.DisplayName))'s account Expiration was set." -ForegroundColor Green 
        <#
        $TermedUserPerms | ForEach-Object{
        Add-ADGroupMember -Identity "$_" -Members $User.DistinguishedName -Credential $logon
        }
        Move-ADObject -Identity $(($User.DistinguishedName)) -TargetPath "OU=Path,OU=To,OU=Termenated,DC=User,DC=Group" -Credential $logon
        Write-Host "$(($User.DisplayName)) has been added to the Terminated Staff Groups and moved to the Terminated Staff OU." -ForegroundColor Magenta
        #>
        }

    Else{

        Read-Host "$Username does not exist. Please check the spelling and try again"
        exit

        }
}

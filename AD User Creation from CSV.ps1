<#
    Title: NewHires.ps1
    Author: TaipanDevil
    Creation Date: TBH I don't remember when I initally created this but it is full version 3

    *NOTES -
            This was my V3 version of my user creation script
            The Script works to create all of the users first and then add them to whatever permission groups you need.

#>
$IMUsers = Import-Csv -Path "\\Path\to\CSV"

$logon = Get-Credential
$DefaultPassword = Read-Host "What is the Default Password?" -AsSecureString
$Domain = "Example.com"
$Pending = 'OU=Path,of=where,to=drop,user=accounts'
$title   = 'Existing User Detected'
$options2 = '&Yes', '&No'
$options1 = '&Yes', '&No','&Change'
$default = 1  # 0=Yes, 1=No , 2=Change

ForEach($User in $IMUsers){
    $username = $User.username
    $firstname = $User.firstname
    $lastname = $User.lastname
    $OU = $Pending
    $telephone = $User.telephone  
    $jobtitle = $User.jobtitle
    $department = $User.department
    $company = $User.Company
    $description = $User.Description
    $EndDate = $User.departdate

    if(Get-ADUser -F { SamAccountName -eq $username }){
        $CU = Get-ADUser $username -Properties *
        $COU = $CU.DistinguishedName -replace '^.*?,(?=[A-Z]{2}=)'
        $msg = "Do you want to move $($CU.DisplayName) from $COU to the Pending OU?"

        Write-Warning "A user account with username $username already exists in Active Directory." 
        Write-Host "`nThe username $username is currently in use by $($CU.DisplayName). They are currently in $COU."

        $response = $Host.UI.PromptForChoice($title, $msg, $options1, $default)

        If($response -eq 0){
            Move-ADObject -Identity $(($CU.DistinguishedName)) -TargetPath $Pending -Credential $logon
            Write-Host "`n$username has been moved to the Pending OU"
            Set-ADAccountPassword -Identity $($CU.SamAccountName) -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$DefaultPassword" -Force) -Credential $logon
            
            
            $params = @{
                Identity              = $($CU.SamAccountName)
                Title                 = $jobtitle
                Description           = $description
                AccountExpirationDate = $((Get-Date).ToString("yyyy.MM.dd HH:mm:ss"))
            }
            Set-ADUser @params
        }
        If($response -eq 2){ 
            $msg2 = "Is there a middle name for $fistname $lastname?"
            $resp2 = $Host.UI.PromptForChoice($title, $msg2, $options1, $default) 
            If($resp2 = 0){
                $M = Read-Host "What is the middle Name/middle initial?"
                $M = "$(($M).Substring(0,1))"
                $username = "$(($firstname).Substring(0,1))$M$lastname"
            }
            If($resp2 = 1){
                $FInitals = 1
                $username = "$(($firstname).Substring(0,$FInitals))$lastname"
                Do{
                    If(Get-ADUser -F { SamAccountName -eq $username }){
                        $FInitals++
                        $username = "$(($firstname).Substring(0,$FInitals))$lastname"
                    } 
                } Until (!(Get-ADUser -F { SamAccountName -eq $username }))
            }

            Write-Host "We will be using the first $FInitals letters of the firstname for $firstname $lastname"
            New-ADUser `
            -SamAccountName $username `
            -UserPrincipalName "$username@$Domain" `
            -Name "$firstname $lastname" `
            -GivenName $firstname `
            -Surname $lastname `
            -EmailAddress "$username@$Domain" `
            -Enabled $True `
            -AccountExpirationDate $((Get-Date).ToString("yyyy.MM.dd HH:mm:ss"))`
            -DisplayName "$firstname $lastname" `
            -Path $OU `
            -Credential $logon `
            -OfficePhone $telephone `
            -Department $department `
            -Company $company `
            -Description $description `
            -Title $jobtitle `
            -AccountPassword $DefaultPassword -ChangePasswordAtLogon $False

        # If user is created, show message.
            Write-Host "The user account $username is created." -ForegroundColor Cyan
            #Start-Sleep -Seconds 5
        }
        Else{
            Write-Host "`n$($CU.DisplayName) was not moved."
        }
    }
    Else{
     New-ADUser `
            -SamAccountName $username `
            -UserPrincipalName "$username@$Domain" `
            -Name "$firstname $lastname" `
            -GivenName $firstname `
            -Surname $lastname `
            -EmailAddress "$username@$Domain" `
            -Enabled $True `
            -AccountExpirationDate $((Get-Date).ToString("yyyy.MM.dd HH:mm:ss"))`
            -DisplayName "$firstname $lastname" `
            -Path $OU `
            -Credential $logon `
            -OfficePhone $telephone `
            -Department $department `
            -Company $company `
            -Description $description `
            -Title $jobtitle `
            -AccountPassword $DefaultPassword -ChangePasswordAtLogon $False

        # If user is created, show message.
        Write-Host "The user account $username is created." -ForegroundColor Cyan
    }
#This is for Temp accounts. Such as Co-op students.
<#
$CU = Get-ADUser $username -Properties *
Switch -Wildcard ($jobtitle){
    '*Student'{
        if($EndDate){
            $date = Get-Date -Date $EndDate
            Set-ADAccountExpiration -Identity $CU.SamAccountName -DateTime ($date.AddDays(1)) -Credential $logon
            Write-Host "Epiration Date Set for $(($CU.SamAccountName))"
        }
    }
}#>}


$StaffOUs = 'Put', 'The', 'Names', 'Of', 'Your', 'Default', 'Permission', 'Groups', 'Here'
$ManagerOUs = 'Second', 'List', 'of', 'Permission', 'Groups'
$TempPath = "\\location\of\dedicated\user\dump\folder" #company I made this for had a collab file share that was labeled with the user's name
$AllPendingUsers = Get-ADUser -Filter * -SearchBase $Pending -Properties *

foreach($user in $AllPendingUsers){
    if($($user.SamAccountName) -like "*admin"){ #For IT staff hires admin accounts had different permissions that were manually added....I did not have permissions to do this.
        Write-Host "The user $($user.DisplayName) is an admin account no group memberships added." -ForegroundColor Yellow
        break
    }
    if($($user.Title) -like "*Manager"){
        ForEach($OU in $ManagerOUs){
            Add-ADGroupMember -Identity "$OU" -Members $user.DistinguishedName -Credential $logon
        }
        Write-Host "The Manager account $($user.Name) has been added to the Manager groups." -ForegroundColor Green
    }
    else{
        ForEach($OU in $StaffOUs){
        Add-ADGroupMember -Identity "$OU" -Members $user.DistinguishedName -Credential $logon
       }
        Write-Host "The Staff account $($user.Name) has been added to the Staff groups." -ForegroundColor Cyan
    }
    $TName = "$(($user.GivenName)) $(($($user.sn)).Substring(0,1))"
    If((Test-Path -Path "$TempPath\$TName") -eq $False){
        New-Item -Path $TempPath -Name $TName -ItemType "directory"
    }
#This is only needed if you are in a hybrid Azure/Entra/Microsoft 365 environment.
<#
    $Exchange = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "Put your on prem exchange URI here" -Credential $logon
    Import-PSSession $Exchange -AllowClobber 
    Enable-RemoteMailbox -Identity $user.UserPrincipalName -RemoteRoutingAddress "$($user.SamAccountName)@example.mail.onmicrosoft.com" | Out-Null  
    Write-Host "RemoteMailbox Enabled for $($user.DisplayName)"
    Remove-PSSession $Exchange #added in case the imported session errors out the rest of the script #>
}


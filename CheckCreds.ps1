Import-Module ActiveDirectory
$cred = Get-Credential #Read credentials
$username = $cred.username
$password = $cred.GetNetworkCredential().password
$today = Get-Date

# Get current domain using logged-on user's credentials
$CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
$domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)


if (Get-ADUser -F { SamAccountName -eq $username }) { #check if user exists
    $CUser = Get-ADUser $username -Properties * 
    $PWSet = Get-Date($CUser.PasswordLastSet)
    $PWExipre = $($PWSet.AddYears(1))
    $DaysLeft = New-TimeSpan -Start "$today" -End "$PWExipre"

    if ($domain.name -eq $null){

        if($CUser.Enabled -eq $false){
            Write-Warning "Authentication failed! -$($CUser.DisplayName) has a disabled account!`n"
        }
        if($CUser.AccountExpirationDate){
                if($CUser.AccountExpirationDate -le $today){
                    Write-Warning "Authentication failed! -$($CUser.DisplayName)'s account expired on $($CUser.AccountExpirationDate)!`n"
                }
        }
        if($CUser.PasswordExpired -eq $true){
            Write-Warning "Authentication failed! -Password for $($CUser.DisplayName) has expired $DaysLeft ago!`n"
        }
        if($CUser.LockedOut -eq $true){
            Write-Warning "Authentication failed! -$($CUser.DisplayName)'s account is locked!`n" 
        }
        if($CUser.PasswordExpired -eq $false){
            Write-Host "The account's current password will exipre in $DaysLeft (Days, Hours, Minutes, Sec.)"
            Get-ADUser $username -Properties * | Select SamAccountName, Enabled, AccountExpirationDate, PasswordExpired, LockedOut
            Read-Host "Press <Enter> to exit."
            Exit
        }
        Else{
            Write-Host "The account's current password will exipre in $DaysLeft (Days, Hours, Minutes, Sec.)"
            Get-ADUser $username -Properties * | Select SamAccountName, Enabled, AccountExpirationDate, PasswordExpired, LockedOut
            Read-Host "Press <Enter> to exit."
            Exit
        }
    }
    Else
    {
        Write-Host "`n$($CUser.DisplayName) Successfully authenticated.`nYour password will exipre in $DaysLeft (Days, Hours, Minutes, Sec.)" -ForegroundColor Cyan
        Get-ADUser $username -Properties * | Select SamAccountName, Enabled, AccountExpirationDate, PasswordExpired, LockedOut
        Read-Host "Press <Enter> to exit."
        Exit
    }
}
Else{
    Write-Host " "
    Write-Warning "Authentication failed for $username - Please double-check the Username." 
    Read-Host "`nPress <Enter> to exit."
}

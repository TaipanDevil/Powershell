<#
    Title: Remote Computer Rename
    Author: Andrew Zeng
    Creation Date: 2025/02/10 @7:49AM MDT
    Rev.:

    This is untested and I am not 100% sure it will work. From my research it should and might just be over complicating it.

#>



$RemotePC = Read-Host "What is the name of the computer you are trying to rename?"
Write-Host "Please provide the local admin account for $($RemotePC):"
$logon1 = Get-Credential
$NewName = Read-Host "What is the new computer name for $($RemotePC)?"
Write-Host "Please provide the domain admin account:"
$logon2 = Get-Credential

Invoke-Command -ComputerName -Credential $logon1 -ScriptBlock {
    
    Rename-Computer -NewName $using:NewName -DomainCredential $using:logon2 -Force -Restart

}


----------------------------------------------------------------------------------------------------------------------------------------

#  Potentially an easier way to get it done.

<#
$login = Get-Credential
$RemotePC = Read-Host "What is the name of the computer you are trying to rename?"
$NewName = Read-Host "What is the new computer name for $($RemotePC)?"

$renameParams = @{
    ComputerName = $RemotePC
    NewName = $NewName
    DomainCredential = $login
    Force = $true
}
Rename-Computer @renameParams

#>

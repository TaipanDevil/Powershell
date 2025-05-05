<#
  Title: Update User Properties
  Author: TaipanDevil
  Creation Date: WIP

  *Notes - 
          This is a a work in progress. As I put this together.
#>
import-module activedirectory

$logon = Get-Credential
$user = Read-Host "Who is the user that you want to update?" 
if ( Get-ADUser -f { DisplayName -eq $user }){
  $user = Get-ADUser -f { DisplayName -eq $user } -Properties *
}
else ( Write-Host "No user with the name $($user).)


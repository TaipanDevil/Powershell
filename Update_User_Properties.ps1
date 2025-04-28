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

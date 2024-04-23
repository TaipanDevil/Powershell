<#
    Title:All Computers in Domain-Remote MSI Install.ps1
    Author: TaipanDevil
    
#>
<#
#******************This Part is if you have multiple OUs holding your computers*******************************
$logon = Get-Credential

$Path = 'C$\Windows\Temp\' #Remote Path on the local Machine
$ProgramName = "NameOfProgram*"

#$MSIName = "NameOfMSI.msi" #Use only if you have more than one Specific MSI

$OUs = 'OU=This,OU=IS,DC=AN,DC=OU', 'OU=This,OU=IS,DC=Another,DC=OU'

        #******************For Logging if you want it. ( I have not found a better way to do this)************************************

#$Part = 1 #Parts are used since it is exporting the nested loop
#$Count = 0 #For the Number of logs
#$Runs = 1 #For the Times this has ran
#Get-ChildItem -Path "\\Put\The\Path\To\Your\Log\Location\HERE" -Recurse -Force | foreach-object {If("$($_.Name)" -like 'ALLCmpInstall-Run? Part1.csv'){ $Runs++ -and $Count++ }}


$OUs | ForEach-Object{
    #$LogName = "AllCompInstall-Run$Runs Part$Part.csv"
    $Computers = Get-ADComputer -Filter * -SearchBase $_ -Properties *
    $Computers | ForEach-Object{
        $RemotePC = $_.Name
        $RPath = '\\' + $RemotePC + '\' + $Path
        $Error.Clear()
        Try{ Invoke-Command -ComputerName $RemotePC -Credential $logon -ScriptBlock{Get-Package $ProgramName} -ErrorAction Stop} #This Checks if the program is already installed the "-ErrorAction Stop" puts the whole error message in plain text
        Catch [System.Management.Automation.Remoting.PSRemotingTransportException] { #This Catches the WinRM errors. Which happens if WinRM is not configured correctly or if the computer is not on the network currently
            Write-Warning "Failed to connect to $RemotePC"
            $Why = $_
            $Status = "Failed"
        } 
        Catch [System.Management.Automation.RemoteException] {
            If($OU -match 'DC=AN'){
                $MSIName = "$(($ProgramName).Replace('*','WhateverDeliniation')).msi" 
                $LMSI = "$($Path.Replace('$',':'))\MSIName.msi"
                $MSIPath = '\\Insert\The\UNC\Path\To\Your\MSI\Here\MSIName.msi' #replace with $MSIName if you have more than one MSI
                Copy-Item -Path $MSIPath -Destination $RPath
                Invoke-Command -ComputerName $RemotePC -Credential $logon -ScriptBlock {
                    Start-Process -FilePath msiexec.exe -ArgumentList "/i $Using:LMSI /quiet /norestart" -Wait 
                } 
                $Status = "Successful"
                Write-Host "$RemotePC was $Status in the install"
                $Why = ""
            }
            Else{
                #$MSIName = ($MSIName).Replace('Onething','Another')
                $LMSI = "$($Path.Replace('$',':'))\MSIName.msi"
                $MSIPath = '\\Insert\The\UNC\Path\To\Your\MSI\Here\MSIName.msi' #replace with $MSIName if you have more than one MSI
                Copy-Item -Path $MSIPath -Destination $RPath
                Invoke-Command -ComputerName $RemotePC -Credential $logon -ScriptBlock {
                    Start-Process -FilePath msiexec.exe -ArgumentList "/i $Using:LMSI /quiet /norestart" -Wait
                } 
                $Status = "Successful"
                Write-Host "$RemotePC was $Status in the install"
                $Why = ""
            }
        }
        If(!$Error){
            $Why = ""
            $Status = "Already Installed"
        }
        [PsCustomObject]@{
            CompName      = $RemotePC
            InstallStatus = $Status
            Error         = $Why
        }
    } #| Export-Csv -Path "\\Path\To\Your\Log\$LogName" -NoTypeInformation
    #$Part++
} #>

#***********************This is the single OU and Single MSI and NO LOGGING**************************************
$logon = Get-Credential
$ProgramName = "NameOfProgram*"
$MsiName = "$(($ProgramName).Replace('*','WhateverDeliniation')).msi" #Or Replace('*',"") if it is just the ProgramName
$Path = 'C$\Windows\Temp\' #Path on the local Machine Windows\Temp will get cleared by windows every now and again.
$MSIPath = '\\Insert\The\UNC\Path\To\Your\MSI\Here\$MsiName'
$OU = 'OU=This,OU=IS,DC=AN,DC=OU'
$Computers = Get-ADComputer -Filter * -SearchBase $OU -Properties *
$Computers | ForEach-Object{
    $RemotePC = $_.Name
    $RPath = '\\' + $RemotePC + '\' + $Path
    $Error.Clear()
    Try{ Invoke-Command -ComputerName $RemotePC -Credential $logon -ScriptBlock{Get-Package $Using:ProgramName} -ErrorAction Stop} #This Checks if the program is already installed the "-ErrorAction Stop" puts the whole error message in plain text
    Catch [System.Management.Automation.Remoting.PSRemotingTransportException] { #This Catches the WinRM errors. Which happens if WinRM is not configured correctly or if the computer is not on the network currently
        Write-Warning "Failed to connect to $RemotePC"
    } 
    Catch [System.Management.Automation.RemoteException] { #This error is if the program is not found on the local machine This is what you want to catch to install the program on computers that do not have it installed
        Copy-Item -Path $MSIPath -Destination $RPath
        $LMSI = "$(($Path).Replace('$',':'))\$MsiName"
        Invoke-Command -ComputerName $RemotePC -Credential $logon -ScriptBlock {
            Start-Process -FilePath msiexec.exe -ArgumentList "/i $Using:LMSI /quiet /norestart" -Wait 
        }
    Write-Host "Install of $ProgramName on $RemotePC was Successful." -ForegroundColor Green
    }
}

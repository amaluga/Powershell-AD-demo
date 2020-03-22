#Part 1 CSV Creation
Set-ExecutionPolicy RemoteSigned

Import-Module C:\Users\Amadeusz.DEMO\Desktop\MyProject\DemoModule.psm1

New-CSV -path C:\Users\Amadeusz.DEMO\Desktop\MyProject\DomainUsers_CSV.csv


#Part 2 Adding members from CSV and managing AD
New-DemoOUs

New-ADUsersFromCSV -path C:\Users\Amadeusz.DEMO\Desktop\MyProject\DomainUsers_CSV.csv

$1stLine = Get-ADUser -Filter 'Title -eq "1st Line Advisor"'
$2ndLine = Get-ADUser -Filter 'Title -eq "2nd Line Advisor"'
$IMs = Get-ADUser -Filter 'Title -eq "Incident Manager"'
$TMs = Get-ADUser -Filter 'Title -eq "Team Manager"'
$CEOs = Get-ADUser -Filter 'Title -eq "CEO"'
$Admins = Get-ADUser -Filter 'Title -eq "Admin"'
$profilesDirs = Get-ProfilesDirs



#creating 1st line/2nd line groups for 4 projects + Admins group
New-DemoGroups

#adding members to groups
Add-DemoADGroupMembers -quantity $1stLine.count -members $1stLine -project '1st'
Add-DemoADGroupMembers -quantity $2ndLine.count -members $2ndLine -project '2nd'
Add-ADGroupMember -identity 'Admins' -Members $Admins
Add-ADGroupMember -identity 'Domain Admins' -Members 'Admins'

###Adding admins and 2nd_project1 line to Remote Desktop Users group
Add-MstscMembers

###Before entering session, please Enable-PSRemoting on server. Domains Admin credentials
$cred = Get-Credential
Invoke-Command -ComputerName WIN-E83VKKDADK7 -Credential $cred `
    -ScriptBlock{ 
    
        ###Creating roaming dirs        
        $using:profilesDirs | 
            ForEach-Object {
                try{
                    New-Item -ItemType Directory -Path C:\Profiles\$_ -ErrorAction Stop
                } catch {
                    Write-Host "$_"
                } 
            }               
    
        ###Also enabled mstsc on the server for 'Remote Desktop Users'
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0;

        ###Sharing dirs, thus creation of roaming profiles available       
        try{
            New-SmbShare `
             -Name "Profiles" `
             -Path 'C:\Profiles' `
             -FullAccess 'Authenticated Users'`
             -ErrorAction Stop
        } catch {
            Write-Host "'Profiles' directory already shared" 
        }
    }
    


###Seting roaming profiles paths
$1stLine | ForEach-Object { Set-ADUser -Identity $_.DistinguishedName -ProfilePath (Set-ProfilePathString 1stLine) }
$2ndLine | ForEach-Object { Set-ADUser -Identity $_.DistinguishedName -ProfilePath (Set-ProfilePathString 2ndLine) }
$IMs | ForEach-Object { Set-ADUser -Identity $_.DistinguishedName -ProfilePath (Set-ProfilePathString IMs) }
$TMs | ForEach-Object { Set-ADUser -Identity $_.DistinguishedName -ProfilePath (Set-ProfilePathString TMs) }
$CEOs | ForEach-Object { Set-ADUser -Identity  $_.DistinguishedName -ProfilePath (Set-ProfilePathString CEOs) }
$admins | ForEach-Object { Set-ADUser -Identity  $_.DistinguishedName -ProfilePath (Set-ProfilePathString Admins)}


try{
    New-GPO -Name 'Disable USB' -ErrorAction Stop | New-GPLink -Target 'OU=1stLine,DC=DEMO,DC=COM' -ErrorAction Stop
}catch {
    Write-Host "GPO already exists"
}

<#Well I've tried to modify this GPO to deny removable storage access with Set-GPRegistryValue but it takes too long time
to find appropriate registry key and change the value, its way much faster to do it in GUI. At least for now I would
recommend creating New-GPOs in Powershell but modifying in GUI or even perform entire GPO actions in GUI.#>








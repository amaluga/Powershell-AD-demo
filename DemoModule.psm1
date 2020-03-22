#used in New-DemoOUs and to create dirs for roaming profiles in Main.ps1
$profilesDirs = @('1stLine', '2ndLine', 'IMs', 'TMs', 'CEOs', 'Admins')

function Get-ProfilesDirs {
    return $profilesDirs
}

###Used in Set-RandomSurname and New-Random Users ADUsers
$nameArr = @( 'Tadeusz', 'Mateusz', 'Marek', 'Andrzej', 'Przemek', 'Piotr', 'Grzegorz', 'Karolina', 'Ewelina', 'Marcelina');
    
###0-4 indexes in surnameArr have to be modified depending on sex
$surnameArr = @( 'Kowalsk', 'Michalowsk', 'Malinowsk', 'Szczepansk', 'Jezowsk', 'Kowalczyk', 'Tracz', 'Maluga', 'Forma'; 'Kot');


function Set-RandomSurname {
    Param([string] $name)    
       
    $surname = $surnameArr | get-random;
    $nameIndex = $surnameArr.IndexOf($surname);    

    if($nameIndex -lt 5){
        if($name.endswith('a')){
            $surname = $surname.insert($surname.length, 'a');
        } else {
            $surname = $surname.insert($surname.length, 'i');
        }
    }  
    return $surname;
}


function Set-DefaultPassword {
    $charsArr = @();
    $digitsArr = @();
    $specialsArr = @();
   

    for($i = 97; $i -lt 123; $i++){
        $charsArr += [char] $i;
    }
           
    for($i = 0; $i -lt 10; $i++){
        $digitsArr += $i;
    }

    for($i = 33; $i -lt 48; $i++){
        if(($i -eq 34) -or ($i -eq 39)){
            continue;
        }
        $specialsArr += [char] $i;
    }

    #Password requirements: At least 1 upperCase, 3 digits, 1 special, 8-10 length
   
    $password = @();
    
    $uppCount = 0;
    $digitCount = 0;
    $specialCount = 0;
    $counter = 0;

    for($i = 0; $i -lt (8..10 | get-random); $i++){       
        if($uppCount -lt 1){
            $password += ($charsArr | get-random).ToString().ToUpper();
            $uppCount++;

        } elseif ($digitCount -lt 3){
            $password += $digitsArr | get-random;
            $digitCount++;
                   

        } elseif ($specialCount -lt 1){
            $password += $specialsArr | get-random;
            $specialCount++;
                   
        } else {
            $password += ($charsArr +$digitsArr + $specialsArr) | get-random;
        }
    }
    return "$password".replace(" ","");
}


function Set-SamAccountName {
    Param([Parameter(Mandatory = $true)] [string]$name,
    [Parameter(Mandatory = $true)] [string]$surname
    )

    ### SamAccountName will contain first letter of name and 6 letters of surname
    # if surname is shorter than 6 chars, then full surname included 
    
    try {
        $samAccountName = ($name.Substring(0, 1) + $surname.Substring(0, 6)).toUpper()
    } catch [ArgumentOutOfRangeException]{
        $samAccountName = ($name.Substring(0, 1) + $surname.Substring(0)).toUpper();
    }


    return $samAccountName
}

function Add-DigitToString {
    Param([Parameter(Mandatory=$true)] [string] $text)

    #example: 1PKOWALS2 (1stLine) digit/string/digit scenario - 2 regex conditions required   
    if( $text -match '(\d+)(\D+)(\d+)'){
        $string = $Matches[1] + $Matches[2]
        $integer = [int]$Matches[3]
        $integer++;
        $text = $string + $integer
    #example: APKOWALS2 (Admin) string/digit scenario
    } elseif ($text -match '(\D+)(\d+)'){
        $string = $Matches[1]
        $integer = [int]$Matches[2]
        $integer++;
        $text = $string + $integer
    } else {
        $text += 1;
    }

    return $text
}


function New-RandomUsers {
    Param([Parameter(Mandatory = $true)] $title,
    [Parameter(Mandatory = $true)] [int] $quantity
    )    

    $randomUsers = @();
    $prefix = '';

    switch($title){
        '1st Line Advisor'{
            $path = 'OU=1stLine, DC=demo, DC=com';
            $prefix = '1';
            break;
        }
        '2nd Line Advisor'{ 
            $path = 'OU=2ndLine, DC=demo, DC=com';
            $prefix = '2';
            break;
        }
        'Team Manager'{
            $path = 'OU=TMs, DC=demo, DC=com';
            $prefix = 'TM';
            break;
        }
        'Incident Manager'{
            $path = 'OU=TMs, DC=demo, DC=com';
            $prefix = 'IM';
            break;
        }
        'Admin'{
            $path = 'OU=TMs, DC=demo, DC=com';
            $prefix = 'A';
            break;
        }
        'CEO'{
            $path = 'OU=TMs, DC=demo, DC=com';
            $prefix = 'C';
            break;
        }
    }
    for($i = 0; $i -lt $quantity; $i++){
        $randomName = ($nameArr | get-random);
        $surName = (Set-RandomSurname -name $randomName);

        $randomUsers += [PSCustomObject]@{'Name' = $randomName;
                                        'Surname' = $surName;
                                        'SamAccountName' = $prefix + (Set-SamAccountName $randomName $surName);
                                        'DisplayName' = $randomName + ' ' + $surName;
                                        'Title' = $title; 
                                        'Department' = 'Lublin';
                                        'Account Password' = Set-DefaultPassword;
                                        'Path' = $path
                                        'Enabled' = $true;
                                        }  
    }

    return $randomUsers;
}


function Avoid-Duplicates{
    Param([Parameter(Mandatory = $true)] [string] $propertyName,
    [Parameter(Mandatory = $true)] [string] $nameToReturn)
    
    #$nameToReturn = $user.Name || $user.SamAccountName in New-AdUsersFromCSV

    $countIfMirrorExists = @();
    
    $countIfMirrorExists += (Get-ADUser -filter "$propertyName -like '$($nameToReturn)*'")

    
    if($countIfMirrorExists.count -gt 0){
        
        $sortedStrings = @()
        $sortedStrings += ($countIfMirrorExists.$propertyName | Group-Object Length | ForEach-Object {$_.group | Sort-Object})
        $lastIndex = $sortedStrings[-1]
        ###Getting last index from the array and adding digit, cause its duplicated        
        $nameToReturn = Add-DigitToString -text $lastIndex;  
    }

    
    return $nameToReturn;
}

function New-CSV {
    Param([Parameter(Mandatory = $true)] $path)
    ### Creating randomized users
    $domainUsers = @();
    $1stLine = New-RandomUsers -title '1st Line Advisor' -quantity 20
    $2ndLine = New-RandomUsers -title '2nd Line Advisor' -quantity 12
    $Admins = New-RandomUsers -title 'Admin' -quantity 2
    $IMs = New-RandomUsers -title 'Incident Manager' -quantity 4
    $TMs = New-RandomUsers -title 'Team Manager' -quantity 4
    $CEOs = New-RandomUsers -title 'CEO' -quantity 1

    $domainUsers += $1stLine + $2ndLine + $Admins + $IMs + $TMs + $CEOs

    $domainUsers | ConvertTo-Csv | Out-File $path
}


function New-ADUsersFromCSV{
    Param([Parameter(Mandatory = $true)] $path)

    $imported = Get-Content $path | ConvertFrom-CSV
    ###Needed to cast 'enabled' property back to boolean, cause during import it's changed data type to string
    $imported | ForEach-Object {$_.enabled = [bool] $_.enabled}

    ### Creating Active Directory accounts
    foreach ($user in $imported){
        $SecPass = $user.'Account Password' | ConvertTo-SecureString -AsPlainText -Force
    
        $ADName = Avoid-Duplicates -propertyName 'Name'-nameToReturn ($user.Name)
        $ADSAN = Avoid-Duplicates -propertyName 'SamAccountName' -nameToReturn ($user.SamAccountName)
        
    
            New-ADUser `
            -Name $ADName `
            -Surname $user.Surname `
            -SamAccountName $ADSAN `
            -DisplayName $user.DisplayName `
            -Title $user.Title `
            -Department  $user.Department `
            -AccountPassword  $SecPass `
            -Path $user.Path `
            -Enabled $user.Enabled
                
    Write-Host "Creating $ADSAN"
        
    }
}


function New-DemoOUs{
    
    $profilesDirs | 
        ForEach-Object -Process {
            try{
                New-ADOrganizationalUnit -Name $_ -Path "DC=demo,DC=com" -ErrorAction Stop
            } catch {
                Write-Host "$_"}
        } 

}

function New-DemoGroups {
    ##creating groups
    $groups1 = @('1st_project1', '1st_project2', '1st_project3', '1st_project4')
    $groups2 = @('2nd_project1', '2nd_project2', '2nd_project3', '2nd_project4')

    
    $groups1 | 
        ForEach-Object -Process {
            try{
                New-ADGroup -Name $_ -GroupScope Global -Path 'OU=1stLine,DC=demo,DC=com' -ErrorAction Stop
            } catch {
                Write-Host "$_"}
        }
            
    $groups2 | 
        ForEach-Object -Process {
            try{
                New-ADGroup -Name $_ -GroupScope Global -Path 'OU=2ndLine,DC=demo,DC=com' -ErrorAction Stop
            } catch {
                Write-Host "$_"
            }
        }

    try{
        New-ADGroup -Name 'Admins' -GroupScope Global -Path 'OU=Admins,DC=demo,DC=com'-ErrorAction Stop
    } catch {
        Write-Host "$_" 
    }   
}       
    

function Add-DemoADGroupMembers {
    Param ([Parameter(Mandatory = $true)] $quantity,
    [Parameter(Mandatory = $true)] $project,
    [Parameter(Mandatory = $true)] $members
    )
    
    if ($project -eq '1st'){
        #1st line
        $identity = '1st_project'
    } elseif ($project -eq '2nd'){
        #2nd line
        $identity = '2nd_project'
    }

    ###divided users for 4 projects
    $divided = $quantity/4
    for($i = 0; $i -lt $quantity; $i++){
   
        switch($i){
            {$i -lt $divided}{ 
                Add-ADGroupMember -Identity ($identity + 1) -Members $members[$i]; 
                break;
            }
            {$i -lt $divided * 2} {
                Add-ADGroupMember -Identity ($identity + 2) -Members $members[$i];
                break;
            }
            {$i -lt $divided * 3}{ 
                Add-ADGroupMember -Identity ($identity + 3) -Members $members[$i];
                break;
            }
            {$i -lt $divided * 4}{ 
                Add-ADGroupMember -Identity ($identity + 4) -Members $members[$i];
                break;
            }
        }

    }
}

###Adding admins and 2nd_project1 line to mstsc group
function Add-MstscMembers{
    Add-ADGroupMember 'Remote Desktop Users' -Members Admins, 2nd_project1
}

function Set-ProfilePathString{
    Param([Parameter(Mandatory = $true)] $string)
    
    $profilePath = '\\WIN-E83VKKDADK7\Profiles\' + $string + '\%username%'

    return $profilePath
}




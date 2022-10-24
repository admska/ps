# Variables
Remove-Variable * -ErrorAction SilentlyContinue
$exportPath = "C:\ADM\MUN\Export\MUN_Operators_$(get-date -format `"yyyyMMdd_hhmmsstt`").csv"
$users = get-content -path "C:\ADM\MUN\Users_import.txt"
$counter = 0

#Funkcija
foreach ($user in $users) {
    $counter++
    Write-Progress -Id 0 -Activity 'Checking User' -Status "Processing $($counter) of $($users.count)" -CurrentOperation $user -PercentComplete (($counter/$users.Count) * 100)
    Start-Sleep -Milliseconds 50
    $ADuser = Get-ADUser $user -Properties * | select SamAccountName,enabled,AccountExpirationDate,LastLogonDate,Modified,Mail,targetAddress,Country,co,@{Name="preferredDataLocation";Expression={$_."msDS-preferredDataLocation"}},Name
    $userobj = $(try {Get-ADUser $user -Properties SamAccountName} catch {$Null})
    If ($userobj -ne $Null) {
        Write-Host "$user exists" -foregroundcolor "green"
        $UserExists = $true
    } else {
        Write-Host "$user not found " -foregroundcolor "red"
        $CSVuser = $User
        $UserExists = $false
        $ADuser.SamAccountName = $Null
        $ADuser.enabled = $Null
        $ADuser.AccountExpirationDate = $Null
        $ADuser.LastLogonDate = $Null
        $ADuser.Modified = $Null
        $ADuser.Mail = $Null
        $ADuser.targetAddress = $Null
        $ADuser.co = $Null
        $ADuser.Country = $Null
        $ADuser.preferredDataLocation = $Null
        $ADuser.Name = $Null
    }

    $WriteObject = New-Object PSObject
    $WriteObject | Add-Member NoteProperty -Name "CSV User" -Value $User
    $WriteObject | Add-Member NoteProperty -Name "Exists in AD" -Value $UserExists
    $WriteObject | Add-Member NoteProperty -Name "Sam Account Name" -Value $ADuser.SamAccountName
    $WriteObject | Add-Member NoteProperty -Name "Enabled in AD" -Value $ADuser.enabled
    $WriteObject | Add-Member NoteProperty -Name "Account Expiration Date" -Value $ADuser.AccountExpirationDate
    $WriteObject | Add-Member NoteProperty -Name "Last Logon Date" -Value $ADuser.LastLogonDate
    $WriteObject | Add-Member NoteProperty -Name "Modified" -Value $ADuser.Modified
    $WriteObject | Add-Member NoteProperty -Name "Mail" -Value $ADuser.mail
    $WriteObject | Add-Member NoteProperty -Name "Target Address" -Value $ADuser.targetAddress
    $WriteObject | Add-Member NoteProperty -Name "Country" -Value $ADuser.co
    $WriteObject | Add-Member NoteProperty -Name "Country Code" -Value $ADuser.Country
    $WriteObject | Add-Member NoteProperty -Name "Preferred Data Location" -Value $ADuser.preferredDataLocation
    $WriteObject | Add-Member NoteProperty -Name "Name" -Value $ADuser.Name
    $WriteObject | Export-CSV $ExportPath -Append -NoTypeInformation
}

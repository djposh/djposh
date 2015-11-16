$ReportsPath = "$HOME\reports"
if ((Test-Path $ReportsPath) -eq $false){
    mkdir $ReportsPath
} 
cd $ReportsPath
$OutFile = "$ReportsPath\UserObjects.txt"

$TooOld = (Get-Date).AddDays(-90)
$users = Get-aduser -filter {Name -like "*"} -properties whenChanged, Enabled, PasswordNeverExpires, EmailAddress, ProfilePath, ScriptPath, HomeDrive
$sum = ($users | where {$_.enabled -eq $true -and $_.whenChanged -gt $TooOld} | Measure-Object).Count
"Number of active users is $sum`t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($users | where {$_.enabled -eq $false} | Measure-Object).Count
"Number of disabled users is $sum`t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($users| where {$_.whenChanged -lt $TooOld -and $_.PasswordNeverExpires -eq $false} | Measure-Object).Count
"Number of inactive useres is $sum `t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($users | where {$_.PasswordNeverExpires -eq $true} | Measure-Object).Count
"Number of useres with PasswordNeverExpires set is $sum `t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($users | where {$_.EmailAddress -ne $null} | Measure-Object).Count
"Number of useres with EmailAddress is $sum `t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($users | where {$_.ProfilePath -ne $null} | Measure-Object).Count
"Number of useres with Profile set is $sum `t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($users | where {$_.HomeDrive -ne $null} | Measure-Object).Count
"Number of useres with HomeDrive set is $sum `t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($users | where {$_.ScriptPath -ne $null} | Measure-Object).Count
"Number of useres with Login Script set is $sum `t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($users | where {$_.ScriptPath -ne $null} | Select-Object ScriptPath  -Unique | Measure-Object).Count
"Number of Login Scripts set at user level is $sum `t`n" | Out-File $OutFile -Encoding unicode -Append
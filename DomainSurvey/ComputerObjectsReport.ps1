$ReportsPath = "$HOME\reports"
if ((Test-Path $ReportsPath) -eq $false){
    mkdir $ReportsPath
} 
cd $ReportsPath
$OutFile = "$ReportsPath\ComputerObjects.txt"

$TooOld = (Get-Date).AddDays(-90)
$hosts = Get-ADComputer -filter {OperatingSystem -like "*server*"} -properties whenChanged, OperatingSystem, Enabled
$sum = ($hosts | where {$_.enabled -eq $true -and $_.whenChanged -gt $TooOld} | Measure-Object).Count
"Servers`n`t" | Out-File $OutFile -Encoding unicode -Append
"Number of active servers is $sum`t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($hosts | where {$_.enabled -eq $false} | Measure-Object).Count
"Number of disabled servers is $sum`t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($hosts | where {$_.whenChanged -lt $TooOld} | Measure-Object).Count
"Number of inactive servers is $sum `t`n`t`n" | Out-File $OutFile -Encoding unicode -Append

$hosts = Get-ADComputer -filter {OperatingSystem -notlike "*server*"} -properties whenChanged, OperatingSystem, Enabled
$sum = ($hosts | where {$_.enabled -eq $true -and $_.whenChanged -gt $TooOld} | Measure-Object).Count
"Workstations`n`t" | Out-File $OutFile -Encoding unicode -Append
"Number of active computers is $sum`t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($hosts | where {$_.enabled -eq $false} | Measure-Object).Count
"Number of disabled computers is $sum`t`n" | Out-File $OutFile -Encoding unicode -Append
$sum = ($hosts | where {$_.whenChanged -lt $TooOld} | Measure-Object).Count
"Number of inactive computers is $sum `t`n`t`n"  | Out-File $OutFile -Encoding unicode -Append

$hosts = $null
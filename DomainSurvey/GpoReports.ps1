$ReportsPath = "$HOME\reports"
if ((Test-Path $ReportsPath) -eq $false){
    mkdir $ReportsPath
}
$GPOReportsPath = "$ReportsPath\GPOReports"
if ((Test-Path $GPOReportsPath) -eq $false){
    mkdir $GPOReportsPath
}
cd $ReportsPath
Get-GPO -All | Select-Object ID | foreach {Get-GPOReport -Guid $_.id -ReportType Html -Path $GPOReportsPath\$($_.id).html}
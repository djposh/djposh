$ReportsPath = "$HOME\reports"
if ((Test-Path $ReportsPath) -eq $false){
    mkdir $ReportsPath
}
$GPOReportsPath = "$ReportsPath\GPOReports"
if ((Test-Path $GPOReportsPath) -eq $false){
    mkdir $GPOReportsPath
}
cd $ReportsPath
foreach ($gpo in(Get-GPO -All)){Get-GPOReport -Guid $gpo.id -ReportType Html -Path $GPOReportsPath\$($gpo.DisplayName).$($gpo.id).html}
Get-GPOReport -All -ReportType xml -Path $GPOReportsPath\AllGPOsReport.xml

# This script warns users about certirficates that will expire in
# the next month. It is aimed at Windows 7 clients where the
# New-CertificateNotificationTask CmdLet is not available.
$DialogTitle = "Warning - Title"
$DialogMessage = @"
Warning
Dialog Body
"@

$experationdates = (Get-Childitem Cert:\CurrentUser\my | select NotAfter).notafter
$currentdate = get-date
$warn = $false
foreach ($edate in $experationdates){
    if ($edate -lt $currentdate.AddMonths(1)){
        if($edate -gt $currentdate){
              $warn = $true  
        }
    }
}

if ($warn -eq $true){
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup($dialogmessage, 0, $DialogTitle,0x0)
}

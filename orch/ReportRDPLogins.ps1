
Set-StrictMode -Version 2.0

$ResultCount = "" 
$ResultString = ""
        
$ResultArray = @()
$DayAgo = (get-date).AddDays(-1)

$DCs =  Get-ADDomainController -Filter {IsReadOnly -eq $false} | Select-Object -ExpandProperty Name  
$EventsFilter = @{ 
    LogName = "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"
    StartTime = $DayAgo
    ID = 25 
}
foreach ($Computer in $DCs){
    $Events = Get-WinEvent -ComputerName $computer -FilterHashtable $EventsFilter -ErrorAction SilentlyContinue
    foreach ($Event in $Events){      
        $EventObject = [pscustomobject][ordered]@{
            Computer = $Computer
            LoginTime = $Event.TimeCreated
            User = ($Event.Message.Split("`n")[2]).Split(" ")[1]
            SourceIP = ($Event.Message.Split("`n")[4]).Split(" ")[3]
        }
        $ResultArray += $EventObject 
    } 
}

$ResultCount = $resultArray.Count

if ($ResultCount -gt 0){
    $ResultString = $resultArray | ft -Wrap -AutoSize | Out-String
}

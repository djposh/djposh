#
# Get-InstalledSoftware.ps1
# Produce csv detailing the installed software on each of the active servers in the domain.
#

$TwoMonthsAgo = (get-date).AddMonths(-2)
$DomainServers = Get-ADComputer -filter {whenChanged -gt $TwoMonthsAgo -and OperatingSystem -like "*server*"} -Properties whenChanged,OperatingSystem 

$array =@()
foreach ($server in $DomainServers){
    $servername = $server.name
    $UninstallKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    $reg=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$servername)
    $regkey=$reg.OpenSubKey($UninstallKey)
    $subkeys=$regkey.GetSubKeyNames()
    foreach($key in $subkeys){
        $thiskey=$UninstallKey+"\\"+$key
        $thisSubKey=$reg.OpenSubKey($thiskey)
        $obj = New-Object PSObject
        $obj | Add-Member -MemberType NoteProperty -Name "ServerName" -Value $servername
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $($thisSubKey.GetValue("DisplayName"))
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $($thisSubKey.GetValue("DisplayVersion"))
        $obj | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $($thisSubKey.GetValue("Publisher"))
        $array +=$obj
    }        
    $array | Where-Object {$_.DisplayName -and $_.ServerName -eq $servername} |Select-Object DisplayName,DisplayVersion,Publisher| Export-Csv -path ".\$servername.csv"
}

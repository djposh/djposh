Function Convert-OutputForCSV {
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline)]
        [psobject]$InputObject,
        [parameter()]
        [ValidateSet('Stack','Comma')]
        [string]$OutputPropertyType = 'Comma'
    )
    Begin {
        $PSBoundParameters.GetEnumerator() | ForEach {
            Write-Verbose "$($_)"
        }
        $FirstRun = $True
    }
    Process {
        If ($FirstRun) {
            $OutputOrder = $InputObject.psobject.properties.name
            Write-Verbose "Output Order:`n $($OutputOrder -join ', ' )"
            $FirstRun = $False
            #Get properties to process
            $Properties = Get-Member -InputObject $InputObject -MemberType *Property
            #Get properties that hold a collection
            $Properties_Collection = @(($Properties | Where-Object {
                $_.Definition -match "Collection|\[\]"
            }).Name)
            #Get properties that do not hold a collection
            $Properties_NoCollection = @(($Properties | Where-Object {
                $_.Definition -notmatch "Collection|\[\]"
            }).Name)
            Write-Verbose "Properties Found that have collections:`n $(($Properties_Collection) -join ', ')"
            Write-Verbose "Properties Found that have no collections:`n $(($Properties_NoCollection) -join ', ')"
        }
 
        $InputObject | ForEach {
            $Line = $_
            $stringBuilder = New-Object Text.StringBuilder
            $Null = $stringBuilder.AppendLine("[pscustomobject] @{")

            $OutputOrder | ForEach {
                If ($OutputPropertyType -eq 'Stack') {
                    $Null = $stringBuilder.AppendLine("`"$($_)`" = `"$(($line.$($_) | Out-String).Trim())`"")
                } ElseIf ($OutputPropertyType -eq "Comma") {
                    $Null = $stringBuilder.AppendLine("`"$($_)`" = `"$($line.$($_) -join ', ')`"")                   
                }
            }
            $Null = $stringBuilder.AppendLine("}")
 
            Invoke-Expression $stringBuilder.ToString()
        }
    }
    End {}
}

########Script Starts Here###########


cd $HOME
if ((Test-Path $HOME\reports\) -eq $false){
    mkdir $HOME\reports
} 

$ReportsPath= "$HOME\reports"
cd $ReportsPath
$trace = ""

$TooOld = (Get-Date).AddDays(-90)
$Servers = Get-ADComputer -filter {whenChanged -gt $TooOld -and OperatingSystem -like "*server*" -and Enabled -eq $true} -properties whenChanged, OperatingSystem, OperatingSystemServicePack, Enabled |select Name, OperatingSystem, OperatingSystemServicePack, Enabled
$Servers | Export-Csv -Path $HOME\reports\ADComputers.csv -Encoding Unicode -NoTypeInformation

$CimSessions = @()
$CimDCOMopt = New-CimSessionOption -Protocol dcom
foreach ($server in $Servers){    
    try{
        $cimsession = New-CimSession -SessionOption $CimDCOMopt -ComputerName $server
        if ($CimSession -ne $null){
            $CimSessions += $cimsession
        }else{
            $trace += "Cimsession created for server $server is null `n"
        }
    }catch{
        $trace += "Error creating cimsession for server $server `n"
        $trace += $Error[0].ErrorDetails+ "`n"
    }
}

if ($CimSessions.count -ne 0){
    foreach ($cimsession in $CimSessions){             
        Get-CimInstance -ClassName Win32_computersystemproduct -CimSession $cimsession | select PSComputerName, Name, Vendor | Export-Csv -Append -Encoding Unicode -NoTypeInformation -Path $ReportsPath\SystemProduct.csv
        Get-CimInstance -ClassName Win32_LogicalDisk -CimSession $cimsession | select PSComputerName,SystemName, Name, Description, Size, FreeSpace, FileSystem, QuotasDisabled | Export-Csv -Append -Encoding Unicode -NoTypeInformation -Path $ReportsPath\LogicalDrives.csv
        Get-CimInstance -ClassName Win32_share -CimSession $cimsession | select PSComputerName, Name, Path, Description | Export-Csv -Append -Encoding Unicode -NoTypeInformation -Path $ReportsPath\FileShares.csv        
        Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $cimsession | select PSComputerName, CSName, Caption, CSDVersion, OSArchitecture | Export-Csv -Append -Encoding Unicode -NoTypeInformation -Path $ReportsPath\OperatingSystem.csv
        Get-CimInstance -ClassName Win32_ServerFeature -CimSession $cimsession| select PSComputerName, Name | Export-Csv -Append -Encoding Unicode -NoTypeInformation -Path $ReportsPath\OSFeatures.csv
        Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration  -CimSession $cimsession| where {$_.ipenabled -eq $true} | select PSComputerName,Index, Description, DHCPEnabled, IPAddress, DNSHostName, DNSServerSearchOrder,WinsPrimaryServer |Convert-OutputForCSV  |Export-Csv -Append -Encoding Unicode -NoTypeInformation -Path $ReportsPath\NetworkInterfaces.csv
    }
}

$UninstallArray = @()
foreach ($servername in $Servers){
        $UninstallKey = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    $reg=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$servername)
    $regkey=$reg.OpenSubKey($UninstallKey)
    $subkeys=$regkey.GetSubKeyNames()
    foreach($key in $subkeys){
        $thiskey=$UninstallKey+"\\"+$key
        $thisSubKey=$reg.OpenSubKey($thiskey)
        if ($thisSubKey.GetValue("DisplayName") -ne $null){
            $obj = New-Object PSObject
            $obj | Add-Member -MemberType NoteProperty -Name "ServerName" -Value $servername
            $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $($thisSubKey.GetValue("DisplayName"))
            $obj | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $($thisSubKey.GetValue("DisplayVersion"))
            $obj | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $($thisSubKey.GetValue("Publisher"))
            $UninstallArray += $obj
        }
    }
}

$UninstallArray | Export-Csv -Append -Encoding Unicode -NoTypeInformation -Path $ReportsPath\InstalledSoftware.csv

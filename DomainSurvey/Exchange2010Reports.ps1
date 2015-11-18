$ReportsPath = "$HOME\reports"
if ((Test-Path $ReportsPath) -eq $false){
    mkdir $HOME\reports
} 
cd $ReportsPath

Get-ExchangeServer | select Name, Fqdn, Edition, Domain, ServerRole, DataPath | Export-Csv -NoTypeInformation -Append -Encoding Unicode -Path "$ReportsPath\ExchangeServers.csv"
foreach ($server in Get-MailboxServer){
    Get-MailboxDatabase -Server $server.name -Status | select  Organization, MasterServerOrAvailabilityGroup, LogFolderPath, CircularLoggingEnabled, MountedOnServer, Name, DatabaseSize, EdbFilePath, RpcClientAccessServer, Servers, ProhibitSendQuota, ProhibitSendReceiveQuota, MailboxRetention, PublicFolderDatabase,DeletedItemRetention, RecoverableItemsQuota, RecoverableItemsWarningQuota, ReplayLagTimes, TruncationLagTimes | Export-Csv -NoTypeInformation -Append -Encoding Unicode -Path $ReportsPath\MailboxDatabases.csv
    Get-MailboxDatabaseCopyStatus -Server $server.name | select  MailboxServer,DatabaseName,Status, ActiveCopy, LatestFullBackupTime, CopyQueueLength, ReplayQueueLength | Export-Csv -NoTypeInformation -Append -Encoding Unicode -Path $ReportsPath\MailboxDatabaseCopies.csv
}

Get-PublicFolderDatabase -Status| select Name, Server, DatabaseSize, EdbFilePath, LogFolderPath, CircularLoggingEnabled, LastFullBackup, ItemRetentionPeriod, MaxItemSize, ProhibitPostQuota, DeletedItemRetention | Export-Csv -NoTypeInformation -Append -Encoding Unicode -Path $ReportsPath\PublicFolderDatabases.csv
Get-EmailAddressPolicy | select Name, Enabled, Priority, RecipientFilter, RecipientContainer, EnabledEmailAddressTemplates, EnabledPrimarySMTPAddressTemplate, RecipientFilterApplied | Export-Csv -NoTypeInformation -Append -Encoding Unicode -Path $ReportsPath\EmailAddressPolicies.csv
Get-ClientAccessArray | select Name, Fqdn, SiteName, Members | Export-Csv -NoTypeInformation -Append -Encoding Unicode -Path $ReportsPath\CASArray.csv
Get-ClientAccessServer | select Name, OutlookAnywhereEnabled,AutoDiscoverServiceInternalUri | Export-Csv -NoTypeInformation -Append -Encoding Unicode -Path $ReportsPath\CASServers.csv
Get-SendConnector | select Name, Enabled, AddressSpaces, HomeMtaServerId, SourceTransportServers, SourceIPAddress, SmartHostsString, SmartHostAuthMechanism, RequireOorg, RequireTLS | Export-Csv -NoTypeInformation -Append -Encoding Unicode -Path $ReportsPath\SendConnectors.csv
Get-ReceiveConnector | select Identity, Enabled, Name, Server, Bindings, RemoteIPRanges, AuthMechanism, DomainSecureEnabled | Export-Csv -NoTypeInformation -Append -Encoding Unicode -Path $ReportsPath\RecieveConnectors.csv


$num = (Get-Mailbox -ResultSize unlimited | measure).Count
"There are $num mailboxes" | Out-File $ReportsPath\NumberOfMailboxes.txt -Encoding unicode -Append
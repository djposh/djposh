$sinceDate = "yyyyMMdd"
$resultOut
$itemcount=0
$strFilter = "(&(ObjectCatergory=Compute(OperatingSystem=*server*)(whenCreated>=$sinceDate))"

$objForest = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest())
#$DomainList = @($objForest.Domains | Select-Object Name)
$DomainList = @($objForest.Domains.Name)

foreach ($Domain in $Domain){
	  $ADsPath = [ADSI]"LDAP://$DOMAIN"
	  $objSearcher = New-Object Ststem.DirectoryServices.DirectorySearcher
	  $objSearcher.SearchRoot = $ADsPath
	  $objSearcher.PageSize = 1000
	  $objSearcher.Filter = $strFilter
	  $objSearcher.SearchScope = "Subtree"
	  
	  $colPropList = "DnsHostName", DistinguishedName", OperatingSystem"
	  foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i)}
	  
	  $colResults = $objSearcher.FindAll()
	  if ($colResults.Count -gt 0){
	    $itemCount=1
	    foreach ($objResult in $colResults){
			$objItem=$objResult.Properties
	    	$objString = "Name" " +$objItem.dnshostname
	    	$objString += "<br/>DN: " " +$objItem.distinguishedname
	      	$objString += "<br/>OS: " " +$objItem.operatingsystem
			$objString += "<br/><br/>"
		    $resultOut += $objString
	    }
		$resultOut
	  }
}
    
    
    
    
  

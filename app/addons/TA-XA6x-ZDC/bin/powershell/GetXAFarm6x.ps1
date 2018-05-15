$snapins  = Get-PSSnapin Citrix.XenApp.Commands -ea 0

if ($snapins -eq $null)
{
   Get-PSSnapin -Registered "Citrix.XenApp.Commands" | Add-PSSnapin
}

                            
$Servers = Get-XAServer  | measure-object | select -ExpandProperty count
$Applications = Get-XAApplication  | measure-object | select -ExpandProperty count

Get-XAFarm | foreach-object {

    $Farm = $_
	if($Farm)
	{
		$output = $Farm | Get-Member -MemberType Properties | where-object{ $_.Name -ne "SessionCount" } | foreach-object {
			$Key = $_.Name
			$Value = $Farm.$Key -join ";" 
			'{0}="{1}"' -f $Key,$Value
		}
		
		$output += '{0}="{1}"' -f "Servers",$Servers
		$output += '{0}="{1}"' -f "Applications",$Applications
		
		Write-Host ("{0:MM/dd/yyyy HH:mm:ss} GMT - {1}" -f ((get-date).ToUniversalTime()),( $output -join " " ))
	}
} 
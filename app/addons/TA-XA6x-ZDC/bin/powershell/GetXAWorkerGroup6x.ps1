$snapins  = Get-PSSnapin Citrix.XenApp.Commands -ea 0

if ($snapins -eq $null)
{
   Get-PSSnapin -Registered "Citrix.XenApp.Commands" | Add-PSSnapin
}

$FarmName = Get-XAFarm | select -ExpandProperty FarmName

Get-XAWorkerGroup | foreach-object {

    $WorkerGroup = $_
    $output = $WorkerGroup | Get-Member -MemberType Properties | foreach-object {
        $Key = $_.Name
        $Value = $WorkerGroup.$Key -join ";" 
        '{0}="{1}"' -f $Key,$Value
    }

    $output += '{0}="{1}"' -f "FarmName",$FarmName
    
    Write-Host ("{0:MM/dd/yyyy HH:mm:ss} GMT - {1}" -f ((get-date).ToUniversalTime()),( $output -join " " ))

} 

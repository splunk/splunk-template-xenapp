$snapins  = Get-PSSnapin Citrix.XenApp.Commands -ea 0

if ($snapins -eq $null)
{
   Get-PSSnapin -Registered "Citrix.XenApp.Commands" | Add-PSSnapin
}

$FarmName = Get-XAFarm | select -ExpandProperty FarmName
$RegexOptions = [System.Text.RegularExpressions.regexoptions]
$SplitRegex = '( )(?=(?:[^"]|"[^"]*")*$)'

foreach( $Application in (Get-XAApplicationReport *) ) {

    $output = foreach( $P in $Application.PsObject.Properties | ? {$_.Name -ne "IconData" }) {
        '{0}="{1}"' -f @($P.Name, ($Application."$($P.Name)" -join ";") )
    }
    
    $output += '{0}="{1}"' -f "FarmName",$FarmName
    
    # The following lines extract just the process name from the CommandLineExecutable property.
    # This is done so we can coorelate perfmon running processes to published applications.
    $ProcessName = "" 
    
    $c = [regex]::Split($Application.CommandLineExecutable, $SplitRegex, $RegexOptions::ExplicitCapture)
    if($c.Length -ge 1 ) {
        $ProcessName = (Split-Path -leaf ( $c[0]  -replace '"','' )) -replace ".exe","" 
    }
    
    $output += '{0}="{1}"' -f "ProcessName", $ProcessName
    
    Write-Host ("{0:MM/dd/yyyy HH:mm:ss} GMT - {1}" -f ((get-date).ToUniversalTime()),( $output -join " " ))
}
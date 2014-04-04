$snapins  = Get-PSSnapin Citrix.XenApp.Commands -ea 0

if ($snapins -eq $null)
{
   Get-PSSnapin -Registered "Citrix.XenApp.Commands" | Add-PSSnapin
}

$FarmName = Get-XAFarm | select -ExpandProperty FarmName
$ScriptRunTime = (get-date).ToFileTime()
$CommandLineExecutable = ""
$ProcessName = ""


Get-XAApplicationReport * | foreach-object {

    $Application = $_
    $output = $Application | Get-Member -MemberType Properties | foreach-object {
        if(-not ( $_.Name -eq "IconData" ) )
        {
            $Key = $_.Name
            $Value = $Application.$Key -join ";"

            if($Key -eq "CommandLineExecutable") { $CommandLineExecutable = $Value }

            '{0}="{1}"' -f $Key,$Value
        }
    }

    $output += '{0}="{1}"' -f "FarmName",$FarmName
    $output += '{0}="{1}"' -f "ScriptRunTime",$ScriptRunTime

    # The following lines extract just the process name from the CommandLineExecutable property.
    # This is done so we can coorelate perfmon running processes to published applications

    $c = $CommandLineExecutable -split '"'

    if($c.Length -gt 1)
    {
        $ProcessName = Split-Path $c[1]  -Leaf

    } else {
        $ProcessName = Split-Path $c[0]  -Leaf
    }

    $output += '{0}="{1}"' -f "ProcessName", $ProcessName.Replace(".exe", "")
    
    Write-Host ("{0:MM/dd/yyyy HH:mm:ss} GMT - {1}" -f ((get-date).ToUniversalTime()),( $output -join " " ))

} 
$snapins  = Get-PSSnapin Citrix.XenApp.Commands -ea 0

if ($snapins -eq $null)
{
   Get-PSSnapin -Registered "Citrix.XenApp.Commands" | Add-PSSnapin
}

$snapins  = Get-PSSnapin Citrix.Common.Commands -ea 0

if ($snapins -eq $null)
{
   Get-PSSnapin -Registered "Citrix.Common.Commands" | Add-PSSnapin
}


function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path $Invocation.MyCommand.Path
}

$FarmName      =   Get-XAFarm | select -ExpandProperty FarmName
$splunk_output =   ""
$udl           =   Join-Path (Get-ScriptDirectory) "ConfigLog.udl"
$positionFile  =   Join-Path (Get-ScriptDirectory) "ConfigLog.position"
$lastRecordID  =   Get-Content -Path $positionFile -ErrorAction Stop
$entries       =   Get-CtxConfigurationLogReport -DataLinkPath $udl | Where-Object { $_.Date -gt $lastRecordID }

if($entries) 
{
    $lastRecordId = $entries[-1].Date

    $entries| foreach-object {

        $entry = $_
        $output = $entry | Get-Member -MemberType Properties | foreach-object {

            $Key = $_.Name
            $Value = $entry.$Key -join ";"

            '{0}="{1}"' -f $Key,$Value

        }

        $output += '{0}="{1}"' -f "FarmName",$FarmName
        $splunk_output += "{0} - {1}`n" -f ($entry.Date),( $output -join " " )
    }

    # Try to write the largest Record ID to the postion file
    try
    {
        Set-Content -Path $positionFile -Value $lastRecordID -ErrorAction Stop
        Write-Host $splunk_output
    }
    catch [System.Exception]
    {
        Write-Error('{0:MM/dd/yyyy HH:mm:ss} GMT - {1} {2}' -f (Get-Date).ToUniversalTime(), "Fatal exception: ", $_.Exception.Message)
        exit
    }
}
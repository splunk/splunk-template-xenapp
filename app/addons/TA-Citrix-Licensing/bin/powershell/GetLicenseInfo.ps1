# Get-CitrixLicensing
Param(
    $LicenseServer = $env:ComputerName
)

$licensePool = Get-wmiobject -class "Citrix_GT_License_Pool" -Namespace "ROOT\CitrixLicensing" -computername $LicenseServer
$ScriptRunTime = (get-date).ToFileTime()

foreach($License in $LicensePool)
{
    $Output  = @()
    $Output += '{0}="{1}"' -f "Product",$License.PLD
    $Output += '{0}="{1}"' -f "Type",$License.LicenseType
    $Output += '{0}="{1}"' -f "Installed",$License.Count
    $Output += '{0}="{1}"' -f "InUse",$License.InUseCount
    $Output += '{0}="{1}"' -f "Available",$License.PooledAvailable
    $Output += '{0}="{1}"' -f "InUse_pct",(($License.InUseCount/$License.Count)*100)
    $Output += '{0}="{1}"' -f "ScriptRunTime",$ScriptRunTime
    
    Write-Host ("{0:MM/dd/yyyy HH:mm:ss} GMT - {1}" -f ((get-date).ToUniversalTime()),( $output -join " " ))
}

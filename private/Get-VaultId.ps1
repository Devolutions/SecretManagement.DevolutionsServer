using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Server

function Get-VaultId {
    [CmdletBinding()]
    param(
        [String] $vaultId
    )
    
    Write-Verbose "Parsing VaultId $($vaultId)" -Verbose:$verboseEnabled
    try {
        $vaultId = [System.Guid]::Parse($vaultId)
        Write-Verbose "$vaultId" -Verbose:$verboseEnabled
    }
    catch {
        Write-Verbose "VaultId is not a valid GUID. Looking for Vault with name: $($vaultId)" -Verbose:$verboseEnabled

        $vaults = Get-DSVaults -Verbose:$verboseEnabled | Select-Object -ExpandProperty originalResponse | ConvertFrom-Json | Select-Object -ExpandProperty data
        foreach ($dsVault in $vaults) {
            if ($dsVault.Name -eq $vaultId) {
                $vaultId = $dsVault.Id 
                break;
            }
        }
    }

    return $vaultId
}

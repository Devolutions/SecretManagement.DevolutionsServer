using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Server

function Get-VaultId {
    [CmdletBinding()]
    param(
        [hashtable] $dsParameters
    )
    
    Write-Verbose "Parsing VaultId $($dsParameters.VaultId)" -Verbose:$verboseEnabled
    try {
        $vaultId = [System.Guid]::Parse($dsParameters.VaultId)
        Write-Verbose "$vaultId" -Verbose:$verboseEnabled
    }
    catch {
        Write-Verbose "VaultId is not a valid GUID. Looking for Vault with name: $($dsParameters.VaultId)" -Verbose:$verboseEnabled

        $vaults = Get-DSVaults -Verbose:$verboseEnabled | Select-Object -ExpandProperty originalResponse | ConvertFrom-Json | Select-Object -ExpandProperty data
        foreach ($dsVault in $vaults) {
            if ($dsVault.Name -eq $dsParameters.VaultId) {
                $vaultId = $dsVault.Id 
                break;
            }
        }
    }

    return $vaultId
}

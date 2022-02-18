using namespace Devolutions.Server

function Remove-Secret
{
    [CmdletBinding()]
    param (
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Get-SecretInfo Vault: $VaultName" -Verbose:$verboseEnabled
    
    $dsParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    Connect-DevolutionsServer($dsParameters);
    Write-Verbose $Global:DSSessionToken -Verbose:$verboseEnabled
    try {
        $vaultId = Get-VaultId($dsParameters) 
        if (-not $vaultId) {
            throw [System.Exception] "Vault $($vaultId) not found."
        }

        $entry = Get-Entry($Name)

        Write-Verbose "Removing $($entry.id)" -Verbose:$verboseEnabled
        Remove-DSEntry -CandidEntryID $entry.id
    }
    catch {
        Write-Error $_.Exception.Message
    }
    finally {
        Disconnect-DevolutionsServer($dsParameters);
    }
}

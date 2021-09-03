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
        $vauldId = Get-VaultId($dsParameters) 
        if (-not $vaultId) {
            throw [System.Exception] "Vault $($vauldId) not found."
        }

        Write-Verbose "Parsing entry name" -Verbose:$verboseEnabled
        $entryId
        try {
            $entryId = [System.Guid]::Parse($Name)
        }
        catch {
            $entryId = Read-Host 'Devolutions Server Entry Id '
        }

        Remove-DSEntry -CandidEntryID $entryId
    }
    catch {
        Write-Error $_.Exception.Message
    }
    finally {
        Disconnect-DevolutionsServer($dsParameters);
    }
}

using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Server

function Get-SecretInfo
{
    [CmdletBinding()]
    param(
        [string] $Filter,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Get-SecretInfo Vault: $VaultName" -Verbose:$verboseEnabled
    
    $dsParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    Connect-DevolutionsServer -VaultName $VaultName -DSParameters $dsParameters

    $vaultId = Get-VaultId($dsParameters)            
    if (-not $vaultId) {
        throw [System.Exception] "Vault $($vauldId) not found."
    }
    
    try {
        $dsEntries = [System.Collections.ArrayList]::new();
        Write-Verbose "Get-DSEntries $($vaultId)" -Verbose:$verboseEnabled

        $entries = (Get-DSEntry -All -VaultId $vaultId).Body.data
        Write-Verbose "$($entries.length) entries in vault."
        foreach ($entry in $entries) {
            try {
                if ($Filter -eq "*" -or $entry.name -match $Filter) {
                    $dsEntries.Add($entry)
                    Write-Verbose "Added $($entry.name)" -Verbose:$verboseEnabled
                }
            }
            catch {
                continue
            }
        }
    
        Write-Verbose "Found Entries: $($dsEntries.Count)" -Verbose:$verboseEnabled
    
        return $dsEntries | ForEach-Object {
            if ($_.group -eq "") {
                $entryName = $_.name
            }
            else {
                $entryName = $_.group + "\" + $_.name
            }

            [Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
                $entryName, 
                [Microsoft.PowerShell.SecretManagement.SecretType]::PSCredential,
                $VaultName, # display name instead of guid when applicable
                @{
                    EntryId = $_.ID
                }
            )
        } | Sort-Object -Property Name -Unique # Multiple entries with the same name are trimmed to prevent issue with SecretManagement
    }
    catch {
        Write-Error $_.Exception.Message
    }
    finally {
        Disconnect-DevolutionsServer($dsParameters);
    }
}

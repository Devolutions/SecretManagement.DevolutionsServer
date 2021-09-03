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
    Connect-DevolutionsServer($dsParameters);

    $vauldId = Get-VaultId($dsParameters)            
    if (-not $vauldId) {
        throw [System.Exception] "Vault $($vauldId) not found."
    }
    
    try {
        $dsEntries = [System.Collections.ArrayList]::new();
        Write-Verbose "Get-DSEntries $($vaultId)" -Verbose:$verboseEnabled
        $entries = Get-DSEntries $vaultId | Select-Object -ExpandProperty originalResponse | ConvertFrom-Json | Select-Object -ExpandProperty data
        
        foreach ($entry in $entries) {
            try {
                $connection = [xml]$entry

                #group check could be more robust
                if ($Filter -eq "*" -or $connection.Connection.Name -match $Filter -and -not $connection.Connection.IsGroup) {
                    $dsEntries.Add($connection)
                    Write-Verbose "Added $($connection.Connection.Name) TYPE: $($connection.Connection.ConnectionType)" -Verbose:$verboseEnabled
                }
            }
            catch {
                continue
            }
        }
    
        Write-Verbose "Found Entries: $($dsEntries.Count)" -Verbose:$verboseEnabled
    
        return $dsEntries | ForEach-Object {
            if ($_.Connection.Group -eq "") {
                $entryName = $_.Connection.Name
            }
            else {
                $entryName = $_.Connection.Group + "\" + $_.Connection.Name
            }

            [Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
                $entryName, 
                [Microsoft.PowerShell.SecretManagement.SecretType]::PSCredential,
                $VaultName, # display name instead of guid when applicable
                @{
                    EntryId = $_.Connection.ID
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

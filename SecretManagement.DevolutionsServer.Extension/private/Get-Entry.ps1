using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Server

function Get-Entry {
    [CmdletBinding()]
    param(
        [string] $name
    )
    
    Write-Verbose "Parsing entry name" -Verbose:$verboseEnabled
    $foundEntry = $null;
    try {
        $entryId = [System.Guid]::Parse($name)
        $foundEntry = (Get-DSEntry -EntryId $entryId -VaultId $vaultId -Verbose:$verboseEnabled).Body.data
    }
    catch {
        Write-Verbose "Entry not valid Guid" -Verbose:$verboseEnabled
        $parsedName = $name -split '\\'
        $entryName = $parsedName[$parsedName.Length - 1];
        if ($parsedName.Length -ge 2) {
            $group = $parsedName[0 .. ($parsedName.Length - 2)] | Join-String -Separator '\'
        }
        else {
            $group = ""
        }

        Write-Verbose "Looking for $($entryName) in $($group)" -Verbose:$verboseEnabled
        $entries = (Get-DSEntry -All -VaultId $vaultId).Body.data
        foreach ($entry in $entries) {
            if ($entry.Group -eq $group -and $entry.Name -eq $entryName) {
                $foundEntry = (Get-DSEntry -EntryId $entry.Id -VaultId $vaultId).Body.data
                Write-Verbose "Entry $name was found" -Verbose:$verboseEnabled
                break;
            }
        }
    }

    return $foundEntry
}
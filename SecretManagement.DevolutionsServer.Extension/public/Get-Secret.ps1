using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Server

function Get-Secret {
    [CmdletBinding()]
    param(
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

        Write-Verbose $Name -Verbose:$verboseEnabled

        $foundEntry = $null;
        Write-Verbose "Parsing entry name" -Verbose:$verboseEnabled
        try {
            $entryId = [System.Guid]::Parse($Name)
            $foundEntry = Get-DSEntry -EntryId $entryId -Verbose:$verboseEnabled
        }
        catch {
            Write-Verbose "Entry not valid Guid" -Verbose:$verboseEnabled
            $parsedName = $Name -split '\\'
            $entryName = $parsedName[$parsedName.Length - 1];
            if ($parsedName.Length -ge 2) {
                $group = $parsedName[0 .. ($parsedName.Length - 2)] | Join-String -Separator '\'
            }
            else {
                $group = ""
            }

            Write-Verbose "Looking for $($entryName) in $($group)" -Verbose:$verboseEnabled
            $entries = ConvertFrom-Json ((Get-DSEntries -VaultId $vaultId).originalResponse.Content)
            foreach ($entry in $entries) {
                if ($entry.Group -eq $group -and $entry.Name -eq $entryName) {
                    $foundEntry = $entry;
                    Write-Verbose "Entry $Name was found" -Verbose:$verboseEnabled
                    break;
                }
            }
        }

        if (-not $foundEntry) {
            Write-Verbose "No entry found" -Verbose:$verboseEnabled
            throw "Entry Not found"
        }
        else {
            if ($foundEntry.connectionType -ne 26) {
                Write-Verbose "Entry of type $($foundEntry.connectionType) was found" -Verbose:$verboseEnabled
                return [PSCredential]::Empty
            }

            Write-Verbose "Retrieving data..." -Verbose:$verboseEnabled
            $endtryData = (ConvertFrom-Json (Get-DSEntry -EntryId $foundEntry.id).originalResponse.Content).data
            
            Write-Verbose "Retrieving sensitive..." -Verbose:$verboseEnabled
            $entrySensitive = Get-DSEntrySensitiveData $foundEntry.id
            $username = $entrySensitive.Body.data.credentials.userName
            $password = $entrySensitive.Body.data.credentials.password

            if (($endtryData.userName -eq "") -and ($foundEntry.Connection.Credentials.Password -eq "")) {
                Write-Verbose "Generating empty credentials" -Verbose:$verboseEnabled
                return [PSCredential]::Empty
            }
            
            if (-not $password -or $password -eq "") {
                Write-Verbose "Generating credentials with empty password" -Verbose:$verboseEnabled
                $securePassword = (new-object System.Security.SecureString)
            }
            else {
                $securePassword = ConvertTo-SecureString -String $password -AsPlainText
            }

            return New-Object PSCredential -ArgumentList ([pscustomobject] @{ UserName = $username; Password = $securePassword[0] }) 
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
    finally {
        Disconnect-DevolutionsServer($dsParameters);
    }
}
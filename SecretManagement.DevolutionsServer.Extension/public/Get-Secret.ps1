using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Server

function Get-Secret {
    [CmdletBinding()]
    param(
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )
    
    $AsPlainText = $AdditionalParameters.ContainsKey('AsPlainText') -and ($AdditionalParameters['AsPlainText'] -eq $true)
    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Get-SecretInfo Vault: $VaultName" -Verbose:$verboseEnabled
    
    try {
        $dsParameters = (Get-SecretVault -Name $VaultName).VaultParameters
        Connect-DevolutionsServer -VaultName $VaultName -DSParameters $dsParameters
        Write-Verbose $Global:DSSessionToken -Verbose:$verboseEnabled

        $vaultId = Get-VaultId($dsParameters) 
        if (-not $vaultId) {
            throw [System.Exception] "Vault $($vaultId) not found."
        }
        
        $foundEntry = Get-Entry($Name)

        if (-not $foundEntry) {
            Write-Verbose "No entry found." -Verbose:$verboseEnabled
            throw "Entry Not found."
        }
        else {
            if ($foundEntry.connectionType -ne 26) {
                Write-Verbose "Entry of type $($foundEntry.connectionType) was found." -Verbose:$verboseEnabled
                return [PSCredential]::Empty
            }

            Write-Verbose "Retrieving data..." -Verbose:$verboseEnabled
            $endtryData = (ConvertFrom-Json (Get-DSEntry -EntryId $foundEntry.id).originalResponse.Content).data
            
            Write-Verbose "Retrieving sensitive..." -Verbose:$verboseEnabled
            $entrySensitive = Get-DSEntrySensitiveData $foundEntry.id
            $username = $entrySensitive.Body.data.credentials.userName
            $password = $entrySensitive.Body.data.credentials.password

            if (($endtryData.userName -eq "") -and ($foundEntry.Connection.Credentials.Password -eq "")) {
                Write-Verbose "Generating empty credentials." -Verbose:$verboseEnabled
                return [PSCredential]::Empty
            }
            
            if (-not $password -or $password -eq "") {
                Write-Verbose "Generating credentials with empty password." -Verbose:$verboseEnabled
                $securePassword = (new-object System.Security.SecureString)
            }
            else {
                $securePassword = ConvertTo-SecureString -String $password -AsPlainText
            }

            if(-not $AsPlainText){
                return New-Object PSCredential -ArgumentList ([pscustomobject] @{ UserName = $username; Password = $securePassword[0] }) 
            }
            else {
                $test = ConvertFrom-SecureString -SecureString $password -AsPlainText
                return @{ UserName = $username; Password = $test }
            }
        }
    }
    catch {
        Write-Error $_.Exception.Message 
    }
    finally {
        Disconnect-DevolutionsServer($dsParameters);
    }
}

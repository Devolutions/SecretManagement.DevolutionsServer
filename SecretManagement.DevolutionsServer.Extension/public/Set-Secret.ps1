using namespace Devolutions.Server

function Set-Secret {
    [CmdletBinding()]
    param (
        [string] $Name,
        [object] $Secret,
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

        switch ($Secret.GetType()) {
            ([pscredential]) {
                $username = $Secret.Username;
                $password = ConvertFrom-SecureString -SecureString $Secret.Password -AsPlainText;
            }
            ([String]) {
                $username = Read-Host 'Username ';
                $password = $Secret;
            }
            ([securestring]) {
                $username = Read-Host 'Username ';
                $password = ConvertFrom-SecureString -SecureString $Secret -AsPlainText
            }
            default {
                throw [System.NotImplementedException] "Provided secret type not supported.";
            }
        }
        
        # null reference in the DS module
        New-DSCredentialEntry -VaultId $vaultId -ConnectionSubType 26 -EntryName $entryName -Username $username -Password $password
        Write-Verbose "Entry Added" -Verbose:$verboseEnabled
    }
    catch {
        Write-Error $_.Exception.Message
    }
    finally {
        Disconnect-DevolutionsServer($dsParameters);
    }
}
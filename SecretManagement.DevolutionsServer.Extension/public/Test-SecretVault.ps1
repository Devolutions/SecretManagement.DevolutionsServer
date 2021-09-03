
function Test-SecretVault {
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Test-SecretVault: $VaultName" -Verbose:$verboseEnabled

    $dsParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    try {
        if (-not $dsParameters.VaultId) {
            throw "Vault Id isn't set."
        }

        Write-Verbose "Parameters : $dsParameters" -Verbose:$verboseEnabled
        Connect-DevolutionsServer($dsParameters)
        return $true
    }
    catch {
        Write-Error $_.Exception.Message
        return $false
    }
    finally {
        Disconnect-DevolutionsServer($dsParameters)
    }
    
}

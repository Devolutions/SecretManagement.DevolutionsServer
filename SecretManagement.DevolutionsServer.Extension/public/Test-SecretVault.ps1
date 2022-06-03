
function Test-SecretVault {
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    if ($AdditionalParameters) {
        $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
        Write-Verbose "Test-SecretVault: $VaultName" -Verbose:$verboseEnabled
    }

    $dsParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    try {
        if (-not $dsParameters.VaultId) {
            throw "Vault Id isn't set."
        }

        Connect-DevolutionsServer -VaultName $VaultName -DSParameters $dsParameters
        return $true
    }
    catch {
        Write-Error $_.Exception.Message
        return $false
    }
    finally {
        $disconnectResult = Disconnect-DevolutionsServer($dsParameters)
    }
}

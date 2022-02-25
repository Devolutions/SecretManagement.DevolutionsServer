function Unlock-DevolutionsServerSecretVault
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$VaultName,
        [Parameter(Mandatory)][SecureString]$Password
        # [hashtable] $AdditionalParameters
    )

    # $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Unlocking Vault: $VaultName" -Verbose:$verboseEnabled
    Set-Variable -Name "Vault_${VaultName}_VaultPassword" -Scope Script -Value $Password -Force

    if (-not (Test-SecretVault -VaultName $VaultName)) {
        Write-Warning "Failed to unlock the vault: ${VaultName}"
        Set-Variable -Name "Vault_${VaultName}_VaultPassword" -Scope Script -Value "" -Force
    }
}

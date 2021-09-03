
function Register-DevolutionsServerSecretVault
{
    [CmdletBinding()]
    param(
        [string] $Name,
        [string] $Url,
        [pscredential] $Credentials,
        [string] $Vault
    )

    $context = New-DSSession -Credential $Credentials -BaseURI $Url

    if (-not $context.isSuccess) {
        Write-Error "Devolutions Server credentials are invalid"
        return
    }

    $vaultId = Get-VaultId($Vault);
    if (-not $vaultId) {
        throw 'Vault could not be found'
    }
    
    $ModuleName = 'SecretManagement.DevolutionsServer'

    Register-SecretVault -ModuleName $ModuleName -Name $Name -VaultParameters @{
        Url = $Url
        Credentials = $Credentials
        VaultId = $VaultId
    }

    if (-not (Get-SecretVault -Name $name)) {
        throw 'SecretVault could not be registered properly'
    }
}

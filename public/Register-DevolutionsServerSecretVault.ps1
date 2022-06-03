
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
        UserName = $Credentials.UserName
        Password = ConvertFrom-SecureString -SecureString $Credentials.Password -AsPlainText
        SafePassword = $Credentials.Password
        Credentials = $Credentials
        VaultId = $vaultId
    }

    if (-not (Get-SecretVault -Name $name)) {
        throw 'SecretVault could not be registered properly'
    }
}

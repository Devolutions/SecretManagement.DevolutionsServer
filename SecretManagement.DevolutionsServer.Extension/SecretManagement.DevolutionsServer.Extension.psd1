@{
    ModuleVersion = '2022.3.2.0'
    RootModule = '.\SecretManagement.DevolutionsServer.Extension.psm1'
    FunctionsToExport = @('Set-Secret','Get-Secret','Remove-Secret','Get-SecretInfo','Test-SecretVault', 'Unlock-DevolutionsServerSecretVault')
}

@{
    ModuleVersion = '0.2'
    RootModule = '.\SecretManagement.DevolutionsServer.Extension.psm1'
    FunctionsToExport = @('Set-Secret','Get-Secret','Remove-Secret','Get-SecretInfo','Test-SecretVault')
}
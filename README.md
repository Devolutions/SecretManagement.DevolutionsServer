# SecretManagement.DevolutionsServer

This module is an implementation of Powershell SecretManagement for Devolutions Server.

**Note:** The _vault id_ and _entry id_ appear in the URL when opening an entry (eg. `http://devolutions.net/server/connections/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).

## Quick Start

Install SecretManagement.DevolutionsServer from [PSGallery](https://www.powershellgallery.com/packages/SecretManagement.DevolutionsServer).

```powershell
Install-Module SecretManagement.DevolutionsServer
```

The vault id appears in the URL when navigating a vault. (eg.
https://devolutions.net/server/connections/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).

Register the vault with the following command:

```powerShell
Register-SecretVault -Name 'SecretVaultName' -ModuleName 'SecretManagement.DevolutionsServer' -VaultParameters @{
    Url = "https://myvault.devolutions.app"
    UserName = "username"
    Password = "P4ssW0rd"
    VaultId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

To confirm that the access to the vault works, use the following command:

```powershell
Test-SecretVault 'SecretVaultName'
```

## Usage

Add an entry to the stored vault:

```powershell
Set-Secret -Vault 'SecretVaultName' -Name 'entryName' -Secret $credentials
```

Get a list of available entries from the stored vault:

```powershell
Get-SecretInfo -Vault 'SecretVaultName'
```

Get an entry using the stored vault. Providing an ID in the name field will be much faster than the entry's name. Only `Credential` entries are supported at the moment.

```powershell
Get-Secret -Vault 'SecretVaultName' -Name 'entryID'
```

Remove an entry from the stored vault.

```powershell
Remove-Secret -Vault 'SecretVaultName' -Name 'entryID'
```

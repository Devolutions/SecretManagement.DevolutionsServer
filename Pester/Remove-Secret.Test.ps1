Describe 'Remove-Secret' {
    BeforeAll {
        $vault = Read-Host 'Secret vault name';

        if (-not (Test-SecretVault -Name $vault)) {
            throw "Vault not configured properly"
        }

        $vaultParameters = (Get-SecretVault -name $vault).VaultParameters

        $url = $vaultParameters.Url
        $pass = ConvertTo-SecureString $vaultParameters.Password -AsPlainText
        $cred = New-Object System.Management.Automation.PSCredential ($vaultParameters.UserName, $pass)
        $vaultId = $vaultParameters.VaultId

        New-DSSession -Credential $cred -BaseUri $url

        $entryName = "pester-test-entry-00F09AEB"
        $folderName = "pester"
        
        $nbInitialEntries = (Get-DSEntry -All -VaultID $vaultId).Body.data.length

        $newEntry = New-DSCredentialEntry -EntryName $entryName -Username "test" -Password "123" -VaultID $vaultId
        $id = $newEntry.Body.data.id

        $newEntry = New-DSCredentialEntry -EntryName $entryName -Username "test" -Password "123" -VaultID $vaultId -Folder $folderName
        $folderId = $newEntry.Body.data.id
        
        $newEntries = @($id, $folderId)
    }

    It 'removes an entry in root' {
        
        $baseEntry = Get-DSEntry -VaultID $vaultId -EntryId $id
        if ($baseEntry.Length -ne 1) {
            # should stop something is wrong
            $false | Should -Be $true
        }
        
        Remove-Secret -Vault $vault -Name $id
        
        New-DSSession -Credential $cred -BaseUri $url
        (Get-DSEntry -VaultID $vaultId -EntryId $id).isSuccess | Should -not -be $true
    }
    It 'removes an entry in a group' {
        $baseEntry = Get-DSEntry -VaultID $vaultId -EntryId $folderId
        if ($baseEntry.Length -ne 1) {
            # should stop something is wrong
            $false | Should -Be $true
        }
        
        Remove-Secret -Vault $vault -Name $folderId
        
        New-DSSession -Credential $cred -BaseUri $url
        (Get-DSEntry -VaultID $vaultId -EntryId $folderId).isSuccess | Should -not -be $true
    }

    AfterAll {
        New-DSSession -Credential $cred -BaseUri $url

        Foreach ($id in $newEntries) {
            Remove-DSEntry -CandidEntryID $id -VaultId $vaultId
        }

        Close-DSSession
    }
}

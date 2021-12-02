Describe 'Get-SecretInfo' {
    BeforeAll {
        $vault = Read-Host 'Vault ';

        if (-not (Test-SecretVault -Name $vault)) {
            throw "Vault not configured properly"
        }

        $url = Read-Host 'url '
        $cred = Get-Credential
        $vaultId = Read-Host "vaultId "

        New-DSSession -Credential $cred -BaseUri $url

        $entryName = "pester-test-entry-00F09AEB"
        $folderName = "pester"
        $entryPass = "pass"
        
        $nbInitialEntries = (Get-DSEntry -All -VaultID $vaultId).Body.data.length

        $newEntry = New-DSCredentialEntry -EntryName $entryName -Username "test" -Password "123" -VaultID $vaultId
        $id = $newEntry.Body.data.id

        $newEntry = New-DSCredentialEntry -EntryName ($entryName + "1") -Username "test" -Password "123" -VaultID $vaultId
        $nameId = $newEntry.Body.data.id

        $newEntry = New-DSCredentialEntry -EntryName $entryName -Username "test" -Password "123" -VaultID $vaultId -Folder $folderName
        $folderId = $newEntry.Body.data.id
        
        $newEntries = @($id, $nameId, $folderId)

        Close-DSSession
    }

    It 'gets all secrets' {
        $total = $nbInitialEntries + 2
        $entries = Get-SecretInfo -Vault $vault
        $entries.Length | Should -BeGreaterThan $total 
    }
    It 'gets secrets based on name' {
        $entries = Get-SecretInfo -Vault $vault -Name $entryName
        $entries.Length | Should -Be 3
    }

    AfterAll {
        New-DSSession -Credential $cred -BaseUri $url

        Foreach ($id in $newEntries) {
            Remove-DSEntry -CandidEntryID $id -VaultId $vaultId
        }

        Close-DSSession
    }
}
Describe 'Get-Secret' {
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
        
        $newEntry = New-DSCredentialEntry -EntryName "pester-test-id" -Username "test" -Password "123" -VaultID $vaultId
        $id = $newEntry.Body.data.id

        $newEntry = New-DSCredentialEntry -EntryName "pester-test-name" -Username "test" -Password "123" -VaultID $vaultId
        $nameId = $newEntry.Body.data.id

        $newEntry = New-DSCredentialEntry -EntryName "pester-folder-test-name" -Username "test" -Password "123" -VaultID $vaultId -Folder "pester"
        $folderId = $newEntry.Body.data.id
        
        $newEntry = New-DSCredentialEntry -EntryName "pester-test-noUser"  -Password "123" -VaultID $vaultId
        $noUserId = $newEntry.Body.data.id
        
        $newEntry = New-DSCredentialEntry -EntryName "pester-test-noPass" -Username "test" -VaultID $vaultId
        $noPassId = $newEntry.Body.data.id
        
        $newEntry = New-DSCredentialEntry -EntryName "pester-test-noCred" -VaultID $vaultId
        $noCredId = $newEntry.Body.data.id
        
        $newEntries = @($id, $nameId, $folderId, $noUserId, $noPassId, $noCredId)

        Close-DSSession
    }

    context 'Get credential' {
        It 'gets entry by Id' {
            $username = "user"
            $entry = Get-Secret -Vault $vault -Name $id
            $entry.UserName | Should -Not -Be $null
        }
        It 'gets entry by name' {
            $username = "user"
            $entry = Get-Secret -Vault $vault -Name "pester-test-name"
            $entry.UserName | Should -Not -Be $null
        }
        It 'gets entry by name in a folder' {
            $username = "GroupUser"
            $entry = Get-Secret -Vault $vault -Name "pester\pester-folder-test-name"
            $entry.UserName | Should -Not -Be $null
        }
    }

    context 'Get partial credential' {
        It 'gets entry without username' {
            $entry = Get-Secret -Vault $vault -Name $noUserId
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Be $null
            $entry.Password.Length | Should -Not -Be 0
        }
        It 'gets entry without password' {
            $entry = Get-Secret -Vault $vault -Name $noPassId
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Not -Be $null
            $entry.Password.Length | Should -Be 0
        }
        It 'gets entry without credentials' {
            $entry = Get-Secret -Vault $vault -Name $noCredId
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Be $null
            $entry.Password.Length | Should -Be 0
        }
    }

    AfterAll {
        New-DSSession -Credential $cred -BaseUri $url

        Foreach ($id in $newEntries) {
            Remove-DSEntry -CandidEntryID $id -VaultId $vaultId
        }

        Close-DSSession
    }
}
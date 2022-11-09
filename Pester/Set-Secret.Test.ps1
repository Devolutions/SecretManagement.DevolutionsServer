Describe 'Set-Secret' {
    BeforeAll {
        $vault = Read-Host 'Secret vault name';

        if (-not (Test-SecretVault -Name $vault)) {
            throw "Vault not configured properly"
        }
    }

    Context 'Secret location' {
        BeforeAll {
            $entryName = "pester-test-entry-00F09AEB"
            $folderName = "pester"
            $entryPass = "pass"
        }
        It 'sets an entry in root' {
            Set-Secret -Vault $vault -Name $entryName $entryPass
            $entry = Get-Secret -Vault $vault -Name $entryName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
        It 'sets an entry in a group' {
            $groupedEntryName = $folderName + "\" + $entryName
            Set-Secret -Vault $vault -Name $groupedEntryName $entryPass
            $entry = Get-Secret -Vault $vault -Name $entryName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
    }

    Context 'Secret using different password types' {
        BeforeAll {
            $entryName = "test-00F09AEC"
            $entryPass = "pass"
            $secureString  = ConvertTo-SecureString -String $entryPass -AsPlainText
            $psCredential = [PSCredential]::new("pester", $secureString)
        }

        It 'sets an entry using PSCredential' {
            $setName = $($entryName + "-psCred")
            Set-Secret -Vault $vault -Name $setName $psCredential
            $entry = Get-Secret -Vault $vault -Name $setName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
        It 'sets an entry using String' {
            $setName = $($entryName + "-string")
            Set-Secret -Vault $vault -Name $setName $entryPass
            $entry = Get-Secret -Vault $vault -Name $setName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
        It 'sets an entry using SecureString' {
            $setName = $($entryName + "-secureString")
            Set-Secret -Vault $vault -Name $setName $secureString
            $entry = Get-Secret -Vault $vault -Name $setName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
    }
}

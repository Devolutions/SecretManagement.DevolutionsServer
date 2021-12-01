Describe 'Get-Secret' {
    BeforeAll {
        $vault = Read-Host 'Vault ';

        if (-not (Test-SecretVault -Name $vault)) {
            throw "Vault not configured properly"
        }
    }

    context 'Get credential' {
        It 'gets entry by Id' {
            $username = "user"
            $entry = Get-Secret -Vault $vault -Name "9beddfbf-7901-415a-802f-772e9ecf009f"
            $entry.UserName | Should -Not -Be $null
        }
        It 'gets entry by name' {
            $username = "user"
            $entry = Get-Secret -Vault $vault -Name "Secret"
            $entry.UserName | Should -Not -Be $null
        }
        It 'gets entry by name in a folder' {
            $username = "GroupUser"
            $entry = Get-Secret -Vault $vault -Name "Pester\Folder-Secret"
            $entry.UserName | Should -Not -Be $null
        }
        # It 'gets entry by name in a virtual folder' {
        #     $username = "VirtualUser"
        #     $entry = Get-Secret -Vault dsSec -Name "Pester\Virtual\Virtual-Secret"
        #     $entry.UserName | Should -Be $username
        # }
    }

    context 'Get partial credential' {
        It 'gets entry without username' {
            $entry = Get-Secret -Vault $vault -Name "noUser"
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Be $null
            $entry.Password.Length | Should -Not -Be 0
        }
        It 'gets entry without password' {
            $entry = Get-Secret -Vault $vault -Name "noPass"
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Not -Be $null
            $entry.Password.Length | Should -Be 0
        }
        It 'gets entry without credentials' {
            $entry = Get-Secret -Vault $vault -Name "noCred"
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Be $null
            $entry.Password.Length | Should -Be 0
        }
    }
}
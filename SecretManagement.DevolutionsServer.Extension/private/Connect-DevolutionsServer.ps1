using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Server

function Connect-DevolutionsServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VaultName,
        [hashtable] $DSParameters
    )
    
    if (-not $DSParameters.VaultId) {
        throw "VaultId not found! Please configure a Devolutions Server VaultId to your SecretVault."
    }
    
    Write-Verbose $DSParameters.VaultId -Verbose:$verboseEnabled
    Write-Verbose 'Connecting to Devolutions Server' -Verbose:$verboseEnabled

    $password = $DSParameters.Password
    if (-not $password) {
        $password = Get-Variable -Name "Vault_${VaultName}_VaultPassword" -ValueOnly
    }

    if (-not $password){
        Write-Verbose 'No Password available' -Verbose:$verboseEnabled
        $p = Read-Host "Password"        
        $sp = ConvertTo-SecureString -String $p -AsPlainText

        Write-Verbose 'Unlocking' -Verbose:$verboseEnabled
        Unlock-DevolutionsServerSecretVault -VaultName $VaultName -Password $sp
        $pass = Get-Variable -Name "Vault_${VaultName}_VaultPassword" -ValueOnly
    }
    else {
        Write-Verbose 'Password was provided' -Verbose:$verboseEnabled
        switch ($password.GetType()) {
            ([securestring]) {
                $pass = $password
            }
            ([string]) {
                $pass = ConvertTo-SecureString -String $password -AsPlainText
            }
        }
    }

    if (-not $pass) {
        Write-Verbose 'Password error' -Verbose:$verboseEnabled
        return
    }

    [pscredential]$creds = New-Object System.Management.Automation.PSCredential ($DSParameters.UserName, $pass)
    
    if ($Global:WebSession)
    {
        # will fail if already connected
        Close-DSSession
    }

    $session = New-DSSession -Credential $creds -BaseURI $DSParameters.Url
    if ($session.isSuccess)
    {
        Write-Verbose 'Connected to Devolutions Server' -Verbose:$verboseEnabled
    }
}
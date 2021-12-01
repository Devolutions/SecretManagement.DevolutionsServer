using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Server

function Connect-DevolutionsServer {
    [CmdletBinding()]
    param(
        [hashtable] $DSParameters
    )
    
    if (-not $DSParameters.VaultId) {
        throw "VaultId not found! Please configure a Devolutions Server VaultId to your SecretVault."
    }
    
    Write-Verbose $DSParameters.VaultId -Verbose:$verboseEnabled
    Write-Verbose 'Connecting to Devolutions Server' -Verbose:$verboseEnabled
    $pass = ConvertTo-SecureString $DSParameters.Password -AsPlainText
    [pscredential]$creds = New-Object System.Management.Automation.PSCredential ($DSParameters.UserName, $pass)
    
    if ($Global:DSSessionToken)
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
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
    
    Write-Verbose 'Running on test version 8.24.11.05' -Verbose:$verboseEnabled
    Write-Verbose $DSParameters.VaultId -Verbose:$verboseEnabled
    # Write-Verbose ConvertFrom-SecureString -SecureString $DSParameters.credentials["Password"] -AsPlainText -Verbose:$verboseEnabled

    Write-Verbose 'Connecting to Devolutions Server' -Verbose:$verboseEnabled
    #make sure not already connected
    #fix credential prompt
    $pass = ConvertTo-SecureString "Masterkey!" -AsPlainText
    [pscredential]$creds = New-Object System.Management.Automation.PSCredential ("sa", $pass)
    Write-Verbose $creds -Verbose:$verboseEnabled
    
    #issue with credential being converted to hashtable 
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
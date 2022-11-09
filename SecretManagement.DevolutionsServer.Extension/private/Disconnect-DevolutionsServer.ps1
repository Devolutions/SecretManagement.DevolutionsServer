using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Server

function Disconnect-DevolutionsServer {
    [CmdletBinding()]
    param(
        [hashtable] $dsParameters
    )
    
    Write-Verbose "Closing Devolutions Server Session" -Verbose:$verboseEnabled
    if ($Global:WebSession)
    {
        Close-DSSession
    }
}

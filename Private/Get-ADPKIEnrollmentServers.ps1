function Get-ADPKIEnrollmentServers {
    <#
            .Synopsis
            Return the Active Directory objects of the Certificate Authorites
            .DESCRIPTION
            Use .net to get the current domain
            .EXAMPLE
            Get-PKIEnrollmentServers
    #>
    [CmdletBinding()]
    [OutputType([adsi])]
    Param(
        [Parameter(Mandatory, HelpMessage = 'Domain To Query', Position = 0)][string]$Domain
    )
    $QueryDN = "LDAP://CN=Enrollment Services,CN=Public Key Services,CN=Services,CN=Configuration,DC={0}" -f $Domain -replace '\.', ',DC=' 
    Write-Verbose -Message "Querying [$QueryDN]"
    $result = [ADSI]$QueryDN
    if (-not ($result.Name)) {
        Throw "Unable to find any Certificate Authority Enrollment Services Servers on domain : $Domain" 
    }
    return $result
}
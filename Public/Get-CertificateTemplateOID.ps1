function Get-CertificateTemplateOID {
    <#
            .Synopsis
            returns a PKI template OID
            .DESCRIPTION
            Connects to LDAP and retrievs the OID of a given PKI template by template Common Name
            .EXAMPLE
            Get-CertificateTemplateOID -Name 'DSCTemplate'
            .EXAMPLE
            Get-CertificateTemplateOID -Name 'DSCTemplate' -Domain contoso.com 
            .OUTPUTS
            System.String
            .NOTES
            This may require RSAT. 
    #>
    [CmdletBinding()]
    [OutputType([String])]
    Param(
        [Parameter(Mandatory, HelpMessage = 'Name of the template')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('cn')] 
        [string]$Name,
        [string]$Domain = $env:USERDNSDOMAIN
    )
    $OIDs = (Get-CertificateTemplate -Domain $domain -TemplateName $Name ).'msPKI-Cert-Template-OID'
    $Return = $OIDs | Foreach-Object {
        [PSCustomObject]@{
            CertificateTemplateOID = $_
        }
    }
    return $Return
}
function Get-CaLocationString {
    <#
        .SYNOPSIS
        Gets the Certificate Authority Location String from active directory

        .DESCRIPTION
        Certificate Authority Location Strings are in the form of ComputerName\CAName This info is contained in Active Directory

        .PARAMETER CAName
        Name given when installing Active Directory Certificate Services

        .PARAMETER ComputerName
        Name of the computer with Active Directory Certificate Services Installed

        .PARAMETER Domain
        Domain to retreve data from

        .EXAMPLE
        get-CaLocationString -CAName MyCA
        Gets only the CA Location String for the CA named MyCA

        .EXAMPLE
        get-CaLocationString -ComputerName ca.contoso.com
        Gets only the CA Location String for server with the DNS name of ca.contoso.com

        .EXAMPLE
        get-CaLocationString -Domain contoso.com
        Gets all CA Location Strings for the domain contoso.com

        .NOTES
        Location string are used to connect to Certificate Authority database and extract data.

        .OUTPUTS
        [STRING[]]
    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [string[]]$CAName,
        [string[]]$ComputerName,
        [String]$Domain = $Env:COMPUTERNAME
    )
    begin {
        $CAList = Get-CertificateAuthority @PSBoundParameters
        $Return = [System.Collections.ArrayList]::New()
    }
    process {
        $CAList | Foreach-Object {
            $o = "{0}\{1}" -f $_.dNSHostName.tostring(), $_.Name.tostring()
            $Return.Add($o) | Out-Null
        }
    }
    end {
        return $Return
    }
}
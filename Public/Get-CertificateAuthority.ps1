function Get-CertificateAuthority {
<#
        .Synopsis
        Get list of Certificate Authorities from Active directory
        .DESCRIPTION
        Queries Active Directory for Certificate Authorities with Enrollment Services enabled
        .EXAMPLE
        Get-CertificatAuthority 
        .EXAMPLE
        Get-CertificatAuthority -CaName 'MyCA'
        .EXAMPLE
        Get-CertificatAuthority -ComputerName 'CA01' -Domain 'Contoso.com'
        .OUTPUTS
        System.DirectoryServices.DirectoryEntry
#>
    [CmdletBinding()]
    [OutputType([adsi])]
    Param(
        [parameter()][string[]]$CAName,
        [parameter()][string[]]$ComputerName,
        [parameter()][String]$Domain = $env:USERDNSDOMAIN
    )
    Write-Verbose $Domain
    $CAList = (Get-ADPKIEnrollmentServers  -Domain $Domain ).Children

    if ($CAName){
        $CAList = $CAList | Where-Object -Property Name -In  -Value $CAName
    }
    if ($ComputerName){
        [System.Collections.ArrayList]$List = @() 
        $ComputerName | Foreach-Object {
            if ($_ -like "*.$Domain"){
                $List.Add($_) | Out-Null
            }
            else {
                $List.add("$($_).$Domain")  | Out-Null
            }
        }
        $CAList = $CAList | Where-Object -Property DNSHostName -In -Value $List
    }
    return $CAList
}

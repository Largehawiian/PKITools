function Get-CertificateTemplate {
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
        [Parameter(HelpMessage = 'Domain To Query', Position = 0)][string]$Domain = $Env:USERDNSDOMAIN,
        [Parameter( HelpMessage = 'Template Name', Position = 1)][string]$TemplateName,
        [Parameter()][Switch]$AllTemplates
    )
    begin {
        $Return = [System.Collections.ArrayList]::new()
    }
    process {
        if ($AllTemplates) {
            $QueryDN = "LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC={0}" -f $Domain -replace '\.', ',DC=' 
            $Results = [ADSI]$QueryDN
            $Results.Children | ForEach-Object {
                $o = [PSCustomObject]@{
                    Name        = $_.Name.ToString()
                    CN          = $_.CN.ToString()
                    DN          = $_.distinguishedName.ToString()
                    DisplayName = $_.DisplayName.ToString()
                    WhenCreated = $_.WhenCreated.ToString()
                    WhenChanged = $_.WhenChanged.ToString()
                    Revision    = $_.Revision.ToString()
                    Path        = $_.Path.ToString()
                }
                $Return.Add($o) | Out-Null
            }
        }
        else {
            $QueryDN = "LDAP://CN={0},CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC={1}" -f $TemplateName, $Domain -replace '\.', ',DC=' 
            Write-Verbose -Message "Querying [$QueryDN]"
            $Return = [ADSI]$QueryDN
            if (!$Return.Name) {
                Throw "$Template was not found in: $Domain" 
            }
        }
    }
    end {
        return $Return
    }
}
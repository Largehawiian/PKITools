function Get-IssuedCertificate {
    [CmdletBinding()]
    Param (
        [Int]$ExpireInDays,
        [String[]]$CAlocation = (Get-CaLocationString),
        [String[]]$Properties,
        [Parameter(ValueFromPipelineByPropertyName)][AllowNull()][String]$CertificateTemplateOid,
        [Parameter(ValueFromPipelineByPropertyName)][AllowNull()][String]$CertificateTemplateName,
        [Parameter(ValueFromPipelineByPropertyName)][AllowNull()][String]$CommonName,
        [AllowNull()][System.Management.Automation.Credential()][PSCredential]$Credential,
        [Switch]$Base64
    ) 
    begin {
        if (!$Properties) {
            $Properties = (
                'Issued Common Name', 
                'Certificate Expiration Date', 
                'Certificate Effective Date', 
                'Certificate Template', 
                #'Issued Email Address',
                'Issued Request ID', 
                'Certificate Hash', 
                #'Request Disposition',
                'Request Disposition Message', 
                'Requester Name', 
                'Binary Certificate' )
        }
        if (!$ExpireInDays) {
            $ExpireInDays = 21900
        }
        $Certs = [System.Collections.ArrayList]::New()
    }
    process {
        try {
            $CaView = New-Object -ComObject CertificateAuthority.View
        }
        catch {
            throw (
                "Unable to create Certificate Authority View. {0} Does not not have ADSC Installed" -f $ENV:COMPUTERNAME
            )
        }
        $CaView.OpenConnection((Get-CaLocationString)) | Out-Null
        $CaView.SetResultColumnCount($Properties.Count)
        $Properties | ForEach-Object {
            $Index = $CaView.GetColumnIndex($false, $_)
            $CaView.SetResultColumn($index)
        }
        $CVR_SEEK_EQ = 1
        $CVR_SEEK_LT = 2
        $CVR_SEEK_GT = 16
        $index = $CaView.GetColumnIndex($false, 'Certificate Expiration Date')
        $now = Get-Date
        $expirationdate = $now.AddDays($ExpireInDays)
        if ($ExpireInDays -gt 0) { 
            $CaView.SetRestriction($index, $CVR_SEEK_GT, 0, $now)
            $CaView.SetRestriction($index, $CVR_SEEK_LT, 0, $expirationdate)
        }
        else {
            $CaView.SetRestriction($index, $CVR_SEEK_LT, 0, $now)
            $CaView.SetRestriction($index, $CVR_SEEK_GT, 0, $expirationdate)
        }
        if ($CertificateTemplateName){
            $OID = Get-CertificateTemplateOID -Name $CertificateTemplateName
            $index = $CaView.GetColumnIndex($false, 'Certificate Template')
            $CaView.SetRestriction($index, $CVR_SEEK_EQ, 0, $oid.CertificateTemplateOID)
        }
        if ($CertificateTemplateOid) {
            $index = $CaView.GetColumnIndex($false, 'Certificate Template')
            $CaView.SetRestriction($index, $CVR_SEEK_EQ, 0, $CertificateTemplateOid)
        }
        if ($CommonName) {
            $index = $CaView.GetColumnIndex($false, 'Issued Common Name')
            $CaView.SetRestriction($index, $CVR_SEEK_EQ, 0, $CommonName)
        }
        $CaView.SetRestriction($CaView.GetColumnIndex($false, 'Request Disposition'), $CVR_SEEK_EQ, 0, 20)
        $CV_OUT_BASE64HEADER = 0 
        $CV_OUT_BASE64 = 1 
        $RowObj = $CaView.OpenView() 
    
        while ($RowObj.Next() -ne -1) {
            $Cert = [PSCustomObject]@{
                DisplayName = ""
            }
            $ColObj = $RowObj.EnumCertViewColumn()
            $ColObj.Next() | Out-Null
            do {
                $displayName = $ColObj.GetDisplayName()
                if ($displayName -eq 'Binary Certificate') {
                    $Cert.Displayname = $($ColObj.GetValue($CV_OUT_BASE64HEADER)) 
                }
                else {
                    $Cert.Displayname = $($ColObj.GetValue($CV_OUT_BASE64))
                }
                $Certs.Add($Cert) | Out-Null
            }
            until ($ColObj.Next() -eq -1)
            Clear-Variable -Name ColObj
        }
    }
    end {
        $Return = [System.Collections.ArrayList]::New()
        $DecodedCerts = [System.Collections.ArrayList]::New()
        $Certs | ForEach-Object {
            if ($Base64) {
                $DecodedCerts.Add($_.DisplayName) | Out-Null
            }
            else {
                $Reader = [System.Security.Cryptography.X509Certificates.X509Certificate2]::New()
                $Encoder = [System.Text.Encoding]::UTF8
                $Bytes = $Encoder.Getbytes($_.DisplayName)
                $Reader.Import($Bytes)
                $DecodedCerts.Add($Reader) | Out-Null
            }
        }
        $DecodedCerts | ForEach-Object {
            if ($_ -notin $Return) {
                $Return.Add($_) | Out-Null
            }
        }
        return $Return
    }
}

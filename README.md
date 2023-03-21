# PKITools
Simple set of functions to get certificate info from Active Directory Certificate Authority

## What it does
Get-CertificateAuthority : Get the Active Directory object of the Certificate Authorities configured to issue certificates on a Domain.

Get-CaLocationString : Get the list of Certificate Authorities on the domain and output the Location Strings used to connect to them. Connection strings are in the form of Server\CAName

Get-ADCertificateTemplate : Gets the Active Directory object of Certificate templates on a domain

Get-CertificateTemplateOID : Gets the OID of a specific template from Active Directory.

Get-IssuedCertificate : Gets Certificates issued by a Certificate Authority. Can be filtered by CommonName, Certificate Template or Days until expire

## Why I created this
Looking on PowerShellGallery.com, I did not find anything that could retrieve certificates from a remote ADCS server and save them to a file. Or get a list of soon to expire Certificates

For example. to get all the certificates that will expire in the next two weeks from all CA's on the current Domain.
~~~
Get-IssuedCertificate -ExpireInDays 14
~~~

Or to save off all the certificates issues for use by Desired State Configuration (DSC)
~~~
$DSCCerts = Get-IssuedCertificate -CertificateTemplateOid (Get-CertificateTemplateOID -Name 'DSCTemplate') -Properties 'Issued Common Name', 'Binary Certificate'
foreach ($cert in $DSCCerts)
{
    set-content -path "c:\certs\$($cert.'Issued Common Name').cer" -Value $cert.'Binary Certificate' -Encoding Ascii
}
~~~


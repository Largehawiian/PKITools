function Get-Domain {
    <#
            .Synopsis
            Return the current domain
            .DESCRIPTION
            Use .net to get the current domain
            .EXAMPLE
            Get-Domain
    #>
    [CmdletBinding()]
    [OutputType([System.DirectoryServices.ActiveDirectory.Domain])]
    param(

    )
    Write-Verbose -Message 'Calling GetCurrentDomain()' 
    return ([DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain())
}
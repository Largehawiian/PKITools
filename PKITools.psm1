$PSScript = $PSScriptRoot
$PublicFunc = @(Get-ChildItem  -Recurse -Path $PSScript\*.ps1 -ErrorAction SilentlyContinue)
Foreach ($Import in $PublicFunc){
    try {
        . $import.fullname
    }
    catch {
        Write-Error -Message "Failled to import function $($import.fullname): $_"
    }
}
Export-ModuleMember -Function $PublicFunc.BaseName
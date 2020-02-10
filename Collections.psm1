
function New-List {
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $Items = @()
    )
    $list = New-Object System.Collections.ArrayList
    foreach ($item in $Items) {
        $list.Add($item) | Out-Null
    }
    return ,$list
}

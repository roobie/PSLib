<#
.SYNOPSIS
Utility functions for creating CAML XML using a DSL

.EXAMPLE
$camlText = caml {
    view {
        where_ {
            eq {
                fieldRef 'ColumnName'
                value 'Text' 'Hello'
            }
        }
    }
}
#>

Import-Module $PSScriptRoot/DebugUtilities.psm1

function Test-ValidateCaml {
    param(
        $camlText
    )
    $x = [XML]$camlText
    if ($null -ne $x.View) {
        $true
    } elseif ($null -ne $x.Where) {
        $true
    } else {
        Get-InformativeCallstack
        throw "Invalid CAML"
    }
}

function Format-Caml {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Block
    )
    & $Block
}

Set-Alias -Name caml -Value Format-Caml

function Format-CamlView {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<View>$(& $Block)</View>"
}

Set-Alias -Name view -Value Format-CamlView

function Format-CamlWhere {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<Where>$(& $Block)</Where>"
}

# not setting alias to `where` because that is already used as Where-Object
Set-Alias -Name where_ -Value Format-CamlWhere

function Format-CamlViewFields {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<ViewFields>$(& $Block)</ViewFields>"
}

Set-Alias -Name viewFields -Value Format-CamlViewFields

function Format-CamlGroupBy {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<GroupBy>$(& $Block)</GroupBy>"
}

Set-Alias -Name groupBy -Value Format-CamlGroupBy

function Format-CamlOrderBy {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        $Block,
        [Parameter(Mandatory = $false)]
        $Override = $null,
        [Parameter(Mandatory = $false)]
        $UseIndexForOrderBy = $null
    )
    $attrs = ""
    if ($null -ne $Override) {
        $attrs += " Override='$(Format-CamlBoolean $Override)'"
    }
    if ($null -ne $UseIndexForOrderBy) {
        $attrs += " UseIndexForOrderBy='$(Format-CamlBoolean $UseIndexForOrderBy)'"
    }

    "<OrderBy$attrs>$(& $Block)</OrderBy>"
}

Set-Alias -Name orderBy -Value Format-CamlOrderBy

function Format-CamlRowLimit {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Value
    )
    "<RowLimit>$Value</RowLimit>"
}

Set-Alias -Name rowLimit -Value Format-CamlRowLimit

function Format-CamlAnd {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<And>$(& $Block)</And>"
}

Set-Alias -Name and -Value Format-CamlAnd

function Format-CamlOr {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<Or>$(& $Block)</Or>"
}

Set-Alias -Name or -Value Format-CamlOr

function Format-CamlEq {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<Eq>$(& $Block)</Eq>"
}

Set-Alias -Name eq -Value Format-CamlEq

function Format-CamlNeq {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<Neq>$(& $Block)</Neq>"
}

Set-Alias -Name neq -Value Format-CamlNeq

function Format-CamlIn {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<In>$(& $Block)</In>"
}

Set-Alias -Name in_ -Value Format-CamlIn

function Format-CamlValues {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<Values>$(& $Block)</Values>"
}

Set-Alias -Name values -Value Format-CamlValues

function Format-CamlIsNull {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<IsNull>$(& $Block)</IsNull>"
}

Set-Alias -Name isNull -Value Format-CamlIsNull

function Format-CamlContains {
    param(
        [Parameter(Mandatory = $true)]
        $Block
    )
    "<Contains>$(& $Block)</Contains>"
}

Set-Alias -Name contains -Value Format-CamlContains

function Format-CamlBoolean {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Value
    )
    if ($Value) {
        "TRUE"
    } else {
        "FALSE"
    }
}

function Format-CamlFieldRef {
    param(
        [Parameter(Mandatory = $true)]
        $FieldInternalName,
        [Parameter(Mandatory = $false)]
        $LookupId = $null,
        [Parameter(Mandatory = $false)]
        $Ascending = $null
    )
    $attrs = ''
    if ($null -ne $LookupId) {
        $attrs += " LookupId='$(Format-CamlBoolean $LookupId)'"
    }
    if ($null -ne $Ascending) {
        $attrs += " Ascending='$(Format-CamlBoolean $Ascending)'"
    }
    "<FieldRef Name='$FieldInternalName' $attrs/>"
}

Set-Alias -Name fieldRef -Value Format-CamlFieldRef

function Format-CamlValue {
    param(
        [Parameter(Mandatory = $true)]
        $Type,
        [Parameter(Mandatory = $true)]
        $Value,
        $IncludeDateTimeValue = $null
    )
    if ($null -ne $IncludeDateTimeValue) {
        "<Value Type='$Type' IncludeDateTimeValue='$(Format-CamlBoolean $IncludeDateTimeValue)'>$Value</Value>"
    } else {
        "<Value Type='$Type'>$Value</Value>"
    }
}

Set-Alias -Name value -Value Format-CamlValue

Export-ModuleMember -Alias * -Function *

function Resolve-Error {
    param(
        [System.Management.Automation.ErrorRecord]$ErrorRecord = $Error[0]
    )
    $ErrorRecord | Format-List * -Force
    $ErrorRecord.InvocationInfo | Format-List *
    $Exception = $ErrorRecord.Exception
    for ($i = 0; $Exception; ++$i, ($Exception = $Exception.InnerException)) {
        "$i" * 80
        $Exception | Format-List * -Force
    }
}

function Get-InformativeCallstack {
    <#
.SYNOPSIS
Yields a string describing the current callstack. This function removes itself from the output,
and if $SkipStack is > 0 it will skip that amount as well.
#>
    param(
        [int]$SkipStack = 0
    )
    $c = 0
    Get-PSCallStack `
      | Select-Object -Skip ($SkipStack) `
      | Where-Object {$_.InvocationInfo.PSCommandPath -notmatch 'DebugUtilities.psm1'} `
      | Foreach-Object {
          $c += 1
          @"
[$($c)] $($_.InvocationInfo | Format-List * | Out-String)
////////////////////////////////////////////////////////////////////////////////
"@
          # $_.InvocationInfo `
            #   | Select-Object -Property `
            #       PositionMessage, `
            #       PSCommandPath, `
            #       InvocationName, `
            #       BoundParameters, `
            #       ScriptLineNumber, `
            #       OffsetInLine `
            #   | Format-List *
      } `
        | Out-String
}

function Test-Assertion {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Test,
        [Parameter(Mandatory = $true)]
        $Message,
        [Parameter(Mandatory = $false)]
        $Fatal = $false
    )
    if (-not $Test) {
        # skip this function
        $debugInfo = Get-InformativeCallstack -SkipStack 1

        if ($Fatal) {
            Throw "$Message $debugInfo"
        } else {
            Write-Error "$Message $debugInfo"
        }
    }
}

function Test-AssertionEq {
    param(
        [Parameter(Mandatory = $true)]
        $Value1,
        [Parameter(Mandatory = $true)]
        $Value2,
        [Parameter(Mandatory = $true)]
        $Message,
        [Parameter(Mandatory = $false)]
        $Fatal = $false
    )
    if ($Value1 -ne $Value2) {
        # skip this function
        $debugInfo = Get-InformativeCallstack -SkipStack 1

        if ($Fatal) {
            Throw "$Message $debugInfo"
        } else {
            Write-Error "$Message $debugInfo"
        }
    }
}

function Trace-Object {
    <#
.SYNOPSIS
Traces the value of the object.
#>
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Object,
        [Switch]$TypeInfo = $false
    )
    Get-PSCallStack | Select-Object -First 1 | `
      %{
          $_.InvocationInfo.PositionMessage
          "+ Value = $($_.InvocationInfo.BoundParameters["Object"])"
      } | Format-List | Out-String
    if (($null -ne $Object) -and $TypeInfo) {
        $t = $Object.GetType()
        $t | Select-Object -Property FullName,Module | Format-List
        # $t.GenericTypeParameters
        # $t.DeclaredConstructors
        # $t.DeclaredEvents
        # $t.DeclaredFields
        # $t.DeclaredMembers
        # $t.DeclaredMethods
        # $t.DeclaredNestedTypes
        # $t.DeclaredProperties
        # $t.Namespace
        # $t.AssemblyQualifiedName
        # $t.FullName
        # $t.Assembly
        # $t.Module
    }
}

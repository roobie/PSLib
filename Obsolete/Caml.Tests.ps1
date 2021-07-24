
Import-Module .\DebugUtilities.psm1
Import-Module .\Collections.psm1
Import-Module .\XmlTools.psm1
Import-Module .\Caml.psm1

$caml = caml {
    view {
        rowLimit 10
        viewFields {
            fieldRef 'ID'
            fieldRef 'Title'
            fieldRef 'Category'
        }
        groupBy {
            fieldRef 'Valid'
        }
        orderBy -Override $true {
            fieldRef 'Modified' -Ascending $false
            fieldRef 'Category'
        }
        where_ {
            and {
                or {
                    neq {
                        fieldRef 'Expired'
                        value 'Integer' 1
                    }
                    isNull {
                        fieldRef 'Expired'
                    }
                }
                or {
                    in_ {
                        fieldRef 'Status'
                        values {
                            value 'Text' 'New'
                            value 'Text' 'InProgress'
                        }
                    }
                    eq {
                        fieldRef 'Title'
                        value 'Text' 'my-title'
                    }
                }
            }
        }
    }
}

$expectedCaml = @"
<View>
  <RowLimit>10</RowLimit>
  <ViewFields>
    <FieldRef Name="ID" />
    <FieldRef Name="Title" />
    <FieldRef Name="Category" />
  </ViewFields>
  <GroupBy>
    <FieldRef Name="Valid" />
  </GroupBy>
  <OrderBy Override="TRUE">
    <FieldRef Name="Modified" Ascending="FALSE" />
    <FieldRef Name="Category" />
  </OrderBy>
  <Where>
    <And>
      <Or>
        <Neq>
          <FieldRef Name="Expired" />
          <Value Type="Integer">1</Value>
        </Neq>
        <IsNull>
          <FieldRef Name="Expired" />
        </IsNull>
      </Or>
      <Or>
        <In>
          <FieldRef Name="Status" />
          <Values>
            <Value Type="Text">New</Value>
            <Value Type="Text">InProgress</Value>
          </Values>
        </In>
        <Eq>
          <FieldRef Name="Title" />
          <Value Type="Text">my-title</Value>
        </Eq>
      </Or>
    </And>
  </Where>
</View>
"@

# (Format-Xml $caml) -eq $expectedCaml | Test-Assertion -Message @"
# CAML markup is not as expected!
# $caml
# $expectedCaml
# "@

Test-ValidateCaml $caml | Test-Assertion -Message 'Invalid CAML'

$v1 = 1
function Test-ATest {
    Test-AssertionEq $v1 2 'asdf'
}
# Test-ATest $ErrorActionPreference 5

# Test-ValidateCaml $caml
# Get-InferredXsd $caml
# $caml | Format-Xml | Write-Host -ForegroundColor Green # | Out-Default


function ml {
    <#

ml {
    Top @{a=b;c=d} {
        Child @{e=f}
    }
}
#>
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Subnodes,
        [Parameter(Mandatory = $false)]
        [System.Collections.HashTable]$Attributes = @{}
    )
    $Subnodes.AST.EndBlock | Format-List *
}

# $a = New-List @(1,2,3,4)
## beware piping an ArrayList (each item will be the target of an invocation)
## $a | Trace-Object -TypeInfo
# Trace-Object $a -TypeInfo
# $b = {out-host 1}
# Trace-Object $b -TypeInfo

using namespace System.IO
using namespace System.Text
using namespace System.Security.Cryptography

function examples {
    # List all loaded types in the current application domain (i.e. the shell itself)
    $types = [AppDomain]::CurrentDomain.GetAssemblies().GetTypes()

    # search for types in a certain namespace
    $types | Where-Object {$_.Namespace -eq 'System.Text'}
    # or
    $types | Where-Object {$_.Namespace -match 'System.Text.*'}

    # view only certain properties of each type:
    $types | Select-Object Name,Namespace,Assembly
}

# function Convert-StringToBytes {
#     param(
#         [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
#         [string]$String,
#         [System.Text.Encoding]$Encoding=[System.Text.Encoding]::UTF8
#     )
#     $Encoding.GetBytes($String)
# }

# function Convert-BytesToString {
#     param(
#         [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
#         [byte[]]$Data,
#         [System.Text.Encoding]$Encoding=[System.Text.Encoding]::UTF8
#     )
#     $Encoding.GetString($Data)
# }

function using1 {
    param($disposable, $blk)
    try{ $result = & $blk } finally { $disposable.Dispose() }
    $result
}

function invokehashalgo {
    param($hashAlgo, $Data)

    using1 $hashAlgo {
        $hashAlgo.ComputeHash($Data)
    }
}

function ConvertTo-MD5 {
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        $Data
    )
    ,(invokehashalgo ([MD5]::Create()) $Data)
}

function ConvertTo-SHA1 {
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        $Data
    )
    ,(invokehashalgo ([SHA1]::Create()) $Data)
}

function ConvertTo-SHA512 {
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        $Data
    )
    ,(invokehashalgo ([SHA512]::Create()) $Data)
}

function ConvertTo-Hash {
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        $Data,
        [ValidateSet('MD5', 'SHA1', 'SHA512')]
        [string]$Algo='MD5'
    )

    if ($Algo -eq 'MD5') {
        ,(ConvertTo-MD5 $Data)
    }
    elseif ($Algo -eq 'SHA1') {
        ,(ConvertTo-SHA1 $Data)
    }
    elseif ($Algo -eq 'SHA512') {
        ,(ConvertTo-SHA512 $Data)
    }
    else {
        throw "Unknown hash algorithm."
    }
}

function hashByteArrayToString {
    param(
        [byte[]]$array
    )
    $sb = New-Object System.Text.StringBuilder
    foreach ($byte in $array) {
        $sb.Append($byte.ToString("X2")) | Out-Null
    }

    $sb.ToString()
}

function Convert-StringToHashString {
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string]$String,
        [Encoding]$Encoding=[Encoding]::UTF8,
        [ValidateSet('MD5', 'SHA1', 'SHA512')]
        [string]$Algo='MD5'
    )
    $bytes = $Encoding.GetBytes($String)
    $hashBytes = ConvertTo-Hash $bytes -Algo $Algo
    hashByteArrayToString $hashBytes
}

function Convert-FileToHashString {
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string]$Path,
        [ValidateSet('MD5', 'SHA1', 'SHA512')]
        [string]$Algo='MD5'
    )
    $stream = [File]::Open($Path, ([FileMode]::Open), ([FileAccess]::Read))
    using1 $stream {
        $hashBytes = ConvertTo-Hash $stream -Algo $Algo
        hashByteArrayToString $hashBytes
    }
}

$private:baseDateTicks = (New-Object DateTime (1900, 1, 1)).Ticks
function Get-SequentialGuid {
<#
Adapted from source code from here:
https://github.com/nhibernate/nhibernate-core/blob/master/src/NHibernate/Id/GuidCombGenerator.cs
#>
    $guidArray = [Guid]::NewGuid().ToByteArray()

    $now = [DateTime]::UtcNow

    # Get the days and milliseconds which will be used to build the byte string
    $days = New-Object TimeSpan ($now.Ticks - $private:baseDateTicks)
    $msecs = $now.TimeOfDay

    # Convert to a byte array
    # Note that SQL Server is accurate to 1/300th of a millisecond so we divide by 3.333333
    $daysArray = [BitConverter]::GetBytes($days.Days)
    $msecsArray = [BitConverter]::GetBytes([long]($msecs.TotalMilliseconds / 3.333333))

    # Reverse the bytes to match SQL Servers ordering
    [Array]::Reverse($daysArray)
    [Array]::Reverse($msecsArray)

    # Copy the bytes into the guid
    [Array]::Copy($daysArray, $daysArray.Length - 2, $guidArray, $guidArray.Length - 6, 2)
    [Array]::Copy($msecsArray, $msecsArray.Length - 4, $guidArray, $guidArray.Length - 4, 4)

    New-Object Guid (,$guidArray)
}

# Export all module members that have a dash in their name.
Export-ModuleMember *-*

Write-Verbose @"
$PSCommandPath
-> $(Convert-FileToHashString $PSCommandPath)
-> $(Convert-FileToHashString $PSCommandPath -Algo SHA1)
-> $(Convert-FileToHashString $PSCommandPath -Algo SHA512)
"@
<#
#>
#<<< EOF >>>

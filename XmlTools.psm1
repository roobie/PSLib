
function Format-Xml {
<#
.SYNOPSIS
Format the incoming text as indented XML.
.EXAMPLE
'<x><m><l/></m></x>' | Format-Xml
#>
    param(
        ## Text of an XML document.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Text
    )

    $doc = [XML]$text
    $sw = New-Object System.Io.Stringwriter
    $writer = New-Object System.Xml.XmlTextWriter($sw)
    $writer.Formatting = [System.Xml.Formatting]::Indented
    $doc.WriteContentTo($writer)
    $sw.ToString()
}

function Test-Xml {
    param(
        $XmlText = $null,
        $Namespace = $null,
        $SchemaFile = $null
    )

    begin {
        $failCount = 0
        $failureMessages = ""
        $fileName = ""
    }

    process {
        $readerSettings = New-Object System.Xml.XmlReaderSettings
        $readerSettings.ValidationType = [System.Xml.ValidationType]::Schema
        $readerSettings.ValidationFlags = `
          [System.Xml.Schema.XmlSchemaValidationFlags]::ProcessInlineSchema -bor `
          [System.Xml.Schema.XmlSchemaValidationFlags]::ProcessSchemaLocation -bor `
          [System.Xml.Schema.XmlSchemaValidationFlags]::ReportValidationWarnings
        $readerSettings.Schemas.Add($Namespace, $SchemaFile) | Out-Null
        $readerSettings.add_ValidationEventHandler(
            {
                $failureMessages = @"
$failureMessages
$fileName - $($_.Message)
"@
                $failCount += 1
            });
        $stringReader = New-Object System.IO.StringReader -ArgumentList "$XmlText"
        $reader = [System.Xml.XmlReader]::Create($stringReader, $readerSettings)
        while ($reader.Read()) { }
        $reader.Close()
    }

    end {
        $failureMessages
        "$failCount validation errors were found"
    }
}

function Get-InferredXsd {
    param(
        $XmlText
    )
    $stringReader = New-Object System.IO.StringReader -ArgumentList "$XmlText"
    $reader = [System.Xml.XmlReader]::Create($stringReader)
    $schemaSet = new-object System.Xml.Schema.XmlSchemaSet
    $schema = new-object System.Xml.Schema.XmlSchemaInference

    $schemaSet = $schema.InferSchema($reader);

    $sb = New-Object System.Text.StringBuilder
    $stringWriter = New-Object System.IO.StringWriter -ArgumentList $sb
    foreach ($s in $schemaSet.Schemas()) {
        $s.Write($stringWriter)
    }
    return $sb.ToString()
}

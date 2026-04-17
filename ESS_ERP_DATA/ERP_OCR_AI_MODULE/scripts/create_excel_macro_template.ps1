param(
    [string]$TemplatePath = "C:\Users\3class_007\git\ESS_ERP\ESS_ERP_DATA\ERP_OCR_AI_MODULE\rpa_logic\templates\ESS_Report_Template.xlsm",
    [string]$MacroModulePath = "C:\Users\3class_007\git\ESS_ERP\ESS_ERP_DATA\ERP_OCR_AI_MODULE\rpa_logic\vba\ESS_Macro_utf8_safe.bas"
)

$ErrorActionPreference = "Stop"

function Get-KoreanSheetName {
    return ([string]([char]44221) + [char]50689 + "_" + [char]50836 + [char]50557)
}

if (-not (Test-Path $MacroModulePath)) {
    throw "Macro module not found: $MacroModulePath"
}

$templateDir = Split-Path -Parent $TemplatePath
if (-not (Test-Path $templateDir)) {
    New-Item -ItemType Directory -Path $templateDir -Force | Out-Null
}

$excel = $null
$workbook = $null
$sheet = $null

try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false
    $excel.AutomationSecurity = 1

    $workbook = $excel.Workbooks.Add()

    while ($workbook.Worksheets.Count -gt 1) {
        $workbook.Worksheets.Item($workbook.Worksheets.Count).Delete()
    }

    $sheet = $workbook.Worksheets.Item(1)
    $sheet.Name = Get-KoreanSheetName

    try {
        $null = $workbook.VBProject.VBComponents.Import($MacroModulePath)
    } catch {
        throw @"
Failed to import VBA module.
Enable Excel option:
File -> Options -> Trust Center -> Trust Center Settings -> Macro Settings ->
'Trust access to the VBA project object model'
Then run this script again.
Original error: $($_.Exception.Message)
"@
    }

    if (Test-Path $TemplatePath) {
        Remove-Item -LiteralPath $TemplatePath -Force
    }

    $xlOpenXMLWorkbookMacroEnabled = 52
    $workbook.SaveAs($TemplatePath, $xlOpenXMLWorkbookMacroEnabled)
    Write-Host "Created template: $TemplatePath"
}
finally {
    if ($workbook -ne $null) {
        $workbook.Close($false)
    }
    if ($excel -ne $null) {
        $excel.Quit()
    }
    if ($workbook -ne $null) {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
    }
    if ($sheet -ne $null) {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet) | Out-Null
    }
    if ($excel -ne $null) {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

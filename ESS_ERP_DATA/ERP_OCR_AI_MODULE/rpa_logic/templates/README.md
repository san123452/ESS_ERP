`ESS_Report_Template.xlsm` must be placed in this folder for `/generate-excel` to return a macro-enabled workbook.

Suggested one-time setup:

1. Open Excel and create a blank workbook.
2. Save it as `ESS_Report_Template.xlsm`.
3. Import [ESS_Macro_utf8_safe.bas](/C:/Users/3class_007/git/ESS_ERP/ESS_ERP_DATA/ERP_OCR_AI_MODULE/rpa_logic/vba/ESS_Macro_utf8_safe.bas) in the VBA editor.
4. Save the workbook into this folder as `ESS_Report_Template.xlsm`.

Or run the helper script once:

`powershell -ExecutionPolicy Bypass -File C:\Users\3class_007\git\ESS_ERP\ESS_ERP_DATA\ERP_OCR_AI_MODULE\scripts\create_excel_macro_template.ps1`

Runtime behavior:

- If `rpa_logic/templates/ESS_Report_Template.xlsm` exists, the API returns `ESS_ERP_Report.xlsm`.
- If the template is missing, `/generate-excel` now fails with a clear server error instead of silently returning `.xlsx`.
- You can override the template path with the `ESS_REPORT_TEMPLATE_PATH` environment variable.

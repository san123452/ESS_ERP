Attribute VB_Name = "ESS_Macro_UTF8_Safe"
Option Explicit

Private Const FONT_UI As String = "Malgun Gothic"
Private Const C_NAVY As Long = 5847334
Private Const C_NAVY_DARK As Long = 5847334
Private Const C_STEEL As Long = 10256749
Private Const C_SLATE As Long = 10256749
Private Const C_GREEN As Long = 8296021
Private Const C_RED As Long = 2832832
Private Const C_AMBER As Long = 5004724
Private Const C_BG As Long = 15525860
Private Const C_PANEL As Long = 16777215
Private Const C_BORDER As Long = 13423047
Private Const C_GRID As Long = 15393757
Private Const C_PANEL_SOFT As Long = 15525860
Private Const C_PANEL_TINT As Long = 15393757
Private Const C_GOLD_SOFT As Long = 7787740
Private Const TARGET_MARGIN As Double = 8#

Private Function K(ByVal a As Variant) As String
    Dim i As Long
    For i = LBound(a) To UBound(a)
        K = K & ChrW$(CLng(a(i)))
    Next i
End Function

Private Function S_Summary() As String: S_Summary = K(Array(44221, 50689, 95, 50836, 50557)): End Function
Private Function S_Monthly() As String: S_Monthly = K(Array(50900, 48324, 95, 49552, 51061)): End Function
Private Function S_Quarterly() As String: S_Quarterly = K(Array(48516, 44592, 48324, 95, 49892, 51201)): End Function
Private Function S_Forecast() As String: S_Forecast = "AI_" & K(Array(51109, 44592)) & "_" & K(Array(50696, 52769)): End Function
Private Function S_Quality() As String: S_Quality = K(Array(54408, 51656, 95, 48516, 49437)): End Function
Private Function S_Cancel() As String: S_Cancel = K(Array(52712, 49548, 95, 48516, 49437)): End Function
Private Function S_Dashboard() As String: S_Dashboard = K(Array(45824, 49884, 48372, 46300)): End Function
Private Function S_Helper() As String: S_Helper = "_" & K(Array(54764, 54140)): End Function

Private Function T_Run() As String: T_Run = K(Array(48372, 44256, 49436, 49436, 32, 49373, 49457)): End Function
Private Function T_Reset() As String: T_Reset = K(Array(52376, 44592, 54868)): End Function
Private Function T_Dash() As String: T_Dash = "ESS " & K(Array(44221, 50689, 49457, 44284, 32, 45824, 49884, 48372, 46300)): End Function
Private Function T_Sub() As String: T_Sub = K(Array(54665, 49900, 51648, 54364, 32, 50836, 50557, 44, 32, 44032, 46021, 49457, 44, 32, 50696, 52769, 32, 48372, 44256, 49436, 49436)): End Function
Private Function T_Bullet() As String: T_Bullet = K(Array(49692, 51060, 51061, 47456, 32, 47785, 54364, 32, 45824, 48708)): End Function
Private Function T_Monthly() As String: T_Monthly = K(Array(50900, 48324, 32, 47588, 52636, 183, 50896, 44032, 32, 48143, 32, 51060, 51061, 47456, 32, 52628, 51060)): End Function
Private Function T_Quarterly() As String: T_Quarterly = K(Array(48516, 44592, 48324, 32, 47588, 52636, 183, 51060, 51061, 32, 48143, 32, 51060, 51061, 47456, 32, 52628, 51060)): End Function
Private Function T_Forecast() As String: T_Forecast = K(Array(49, 50, 44060, 50900, 32, 47588, 52636, 32, 48143, 32, 51060, 51061, 32, 50696, 52769)): End Function
Private Function T_Quality() As String: T_Quality = K(Array(54408, 51656, 32, 48520, 47049, 32, 48516, 49437)): End Function
Private Function T_Cancel() As String: T_Cancel = K(Array(49688, 51452, 32, 52712, 49548, 50984)): End Function

Private Function GetWS(ByVal nm As String) As Worksheet
    On Error Resume Next
    Set GetWS = ThisWorkbook.Worksheets(nm)
    On Error GoTo 0
End Function

Private Function LastDataRow(ByVal ws As Worksheet, ByVal colLetter As String) As Long
    Dim r As Long
    r = ws.Cells(ws.Rows.Count, colLetter).End(xlUp).Row
    If r > 3 Then
        LastDataRow = r - 1
    Else
        LastDataRow = 0
    End If
End Function

Private Sub DropSheet(ByVal nm As String)
    Dim ws As Worksheet
    Set ws = GetWS(nm)
    If Not ws Is Nothing Then
        Application.DisplayAlerts = False
        ws.Delete
        Application.DisplayAlerts = True
    End If
End Sub

Private Sub ClearCharts(ByVal ws As Worksheet)
    Dim co As ChartObject
    For Each co In ws.ChartObjects
        co.Delete
    Next co
End Sub

Private Sub ChartSkin(ByVal ch As Chart, ByVal titleText As String, Optional ByVal showLegend As Boolean = True)
    With ch
        .HasTitle = True
        .ChartTitle.Text = titleText
        .ChartTitle.Font.Name = FONT_UI
        .ChartTitle.Font.Size = 15
        .ChartTitle.Font.Bold = True
        .ChartTitle.Font.Color = C_NAVY
        .ChartArea.Format.Fill.ForeColor.RGB = C_PANEL
        .PlotArea.Format.Fill.ForeColor.RGB = C_PANEL
        .ChartArea.Format.Line.Visible = msoFalse
        .PlotArea.Format.Line.Visible = msoFalse
        .HasLegend = showLegend
        If showLegend And .SeriesCollection.Count > 0 Then
            On Error Resume Next
            .Legend.Position = xlLegendPositionBottom
            .Legend.Font.Name = FONT_UI
            .Legend.Font.Size = 9
            .Legend.Format.Fill.Visible = msoFalse
            .Legend.Format.Line.Visible = msoFalse
            On Error GoTo 0
        End If
    End With
    On Error Resume Next
    ch.Axes(xlCategory).TickLabels.Font.Name = FONT_UI
    ch.Axes(xlCategory).TickLabels.Font.Size = 8.5
    ch.Axes(xlCategory).TickLabels.Font.Color = C_SLATE
    ch.Axes(xlValue).TickLabels.Font.Name = FONT_UI
    ch.Axes(xlValue).TickLabels.Font.Size = 8.5
    ch.Axes(xlValue).TickLabels.Font.Color = C_SLATE
    ch.Axes(xlValue).HasMajorGridlines = True
    ch.Axes(xlValue).MajorGridlines.Format.Line.ForeColor.RGB = C_GRID
    ch.Axes(xlValue).MajorGridlines.Format.Line.Transparency = 0.55
    ch.Axes(xlCategory).Format.Line.ForeColor.RGB = C_BORDER
    ch.Axes(xlValue).Format.Line.ForeColor.RGB = C_BORDER
    ch.Axes(xlCategory).TickLabelSpacing = 2
    ch.Axes(xlCategory).TickLabels.Orientation = 30
    ch.Parent.ShapeRange.Shadow.Visible = msoTrue
    ch.Parent.ShapeRange.Shadow.ForeColor.RGB = C_BORDER
    ch.Parent.ShapeRange.Shadow.Transparency = 0.48
    ch.Parent.ShapeRange.Shadow.OffsetX = 2
    ch.Parent.ShapeRange.Shadow.OffsetY = 2
    ch.Parent.ShapeRange.Shadow.Blur = 6
    On Error GoTo 0
End Sub

Private Sub ForceDonutLabelsOutside(ByVal ch As Chart)
    On Error Resume Next
    Dim s As Series
    Set s = ch.SeriesCollection(1)
    If s Is Nothing Then Exit Sub
    If s.Points.Count < 2 Then Exit Sub

    s.HasLeaderLines = True
    s.Points(1).HasDataLabel = True
    s.Points(2).HasDataLabel = True

    s.Points(1).DataLabel.Left = ch.PlotArea.InsideLeft + (ch.PlotArea.InsideWidth * 0.42)
    s.Points(1).DataLabel.Top = ch.PlotArea.InsideTop + (ch.PlotArea.InsideHeight * 0.82)

    s.Points(2).DataLabel.Left = ch.PlotArea.InsideLeft + (ch.PlotArea.InsideWidth * 0.18)
    s.Points(2).DataLabel.Top = ch.PlotArea.InsideTop + (ch.PlotArea.InsideHeight * 0.02)
    On Error GoTo 0
End Sub

Private Sub SafeDropShape(ByVal ws As Worksheet, ByVal shapeName As String)
    On Error Resume Next
    ws.Shapes(shapeName).Delete
    On Error GoTo 0
End Sub

Private Sub AddDonutCallouts(ByVal ws As Worksheet, ByVal co As ChartObject, ByVal keyName As String, _
                             ByVal smallText As String, ByVal smallColor As Long, _
                             ByVal largeText As String, ByVal largeColor As Long)
    Dim smallBox As Shape, largeBox As Shape
    Dim smallLine As Shape
    Dim largeLine As Shape
    Dim l As Double, t As Double, w As Double, h As Double
    Dim smallBoxLeft As Double, smallBoxTop As Double, smallBoxWidth As Double
    Dim largeBoxLeft As Double, largeBoxTop As Double, largeBoxWidth As Double
    Dim smallLineX1 As Double, smallLineY1 As Double, smallLineX2 As Double, smallLineY2 As Double
    Dim largeLineX1 As Double, largeLineY1 As Double, largeLineX2 As Double, largeLineY2 As Double

    l = co.Left
    t = co.Top
    w = co.Width
    h = co.Height

    SafeDropShape ws, keyName & "_small_box"
    SafeDropShape ws, keyName & "_large_box"
    SafeDropShape ws, keyName & "_small_line"
    SafeDropShape ws, keyName & "_large_line"

    smallBoxLeft = l + 2.6
    smallBoxTop = t + 47.1
    smallBoxWidth = 122

    If keyName = "quality_dash" Then
        largeBoxLeft = l + 265.6
        largeBoxTop = t + 191.1
        largeBoxWidth = 132
        smallLineX1 = l + 23.2
        smallLineY1 = t + 43.9
        smallLineX2 = l + 182.5
        smallLineY2 = t + 45.1
        largeLineX1 = l + 194.7
        largeLineY1 = t + 218.0
        largeLineX2 = l + 322.2
        largeLineY2 = t + 218.0
    Else
        largeBoxLeft = l + 277.9
        largeBoxTop = t + 190.2
        largeBoxWidth = 132
        smallLineX1 = l + 23.1
        smallLineY1 = t + 44.8
        smallLineX2 = l + 173.6
        smallLineY2 = t + 45.1
        largeLineX1 = l + 193.7
        largeLineY1 = t + 215.3
        largeLineX2 = l + 321.2
        largeLineY2 = t + 215.3
    End If

    Set smallBox = ws.Shapes.AddTextbox(msoTextOrientationHorizontal, _
                                        smallBoxLeft, smallBoxTop, smallBoxWidth, 24)
    smallBox.Name = keyName & "_small_box"
    With smallBox
        .Line.Visible = msoFalse
        .Fill.Visible = msoFalse
        .TextFrame2.TextRange.Text = smallText
        .TextFrame2.TextRange.Font.Name = FONT_UI
        .TextFrame2.TextRange.Font.Size = 9.5
        .TextFrame2.TextRange.Font.Bold = msoTrue
        .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = smallColor
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignLeft
        .TextFrame2.VerticalAnchor = msoAnchorMiddle
    End With

    Set largeBox = ws.Shapes.AddTextbox(msoTextOrientationHorizontal, _
                                        largeBoxLeft, largeBoxTop, largeBoxWidth, 24)
    largeBox.Name = keyName & "_large_box"
    With largeBox
        .Line.Visible = msoFalse
        .Fill.Visible = msoFalse
        .TextFrame2.TextRange.Text = largeText
        .TextFrame2.TextRange.Font.Name = FONT_UI
        .TextFrame2.TextRange.Font.Size = 9.5
        .TextFrame2.TextRange.Font.Bold = msoTrue
        .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = largeColor
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignLeft
        .TextFrame2.VerticalAnchor = msoAnchorMiddle
    End With

    Set smallLine = ws.Shapes.AddLine(smallLineX1, smallLineY1, smallLineX2, smallLineY2)
    smallLine.Name = keyName & "_small_line"
    With smallLine.Line
        .ForeColor.RGB = smallColor
        .Weight = 1.5
        .Transparency = 0.15
    End With

    Set largeLine = ws.Shapes.AddLine(largeLineX1, largeLineY1, largeLineX2, largeLineY2)
    largeLine.Name = keyName & "_large_line"
    With largeLine.Line
        .ForeColor.RGB = largeColor
        .Weight = 1.35
        .Transparency = 0.18
    End With
End Sub

Private Sub ApplyCompactAxis(ByVal ch As Chart, Optional ByVal categoryEvery As Long = 2, Optional ByVal categoryAngle As Long = 45)
    On Error Resume Next
    ch.Axes(xlCategory).TickLabelSpacing = categoryEvery
    ch.Axes(xlCategory).TickLabels.Orientation = categoryAngle
    ch.Axes(xlValue).TickLabels.NumberFormat = "0""억"""
    ch.Axes(xlValue).HasMajorGridlines = True
    ch.Axes(xlValue).MajorGridlines.Format.Line.ForeColor.RGB = C_GRID
    On Error GoTo 0
End Sub

Private Sub ApplyKrwAxis(ByVal ch As Chart, Optional ByVal categoryEvery As Long = 2, Optional ByVal categoryAngle As Long = 45)
    On Error Resume Next
    ch.Axes(xlCategory).TickLabelSpacing = categoryEvery
    ch.Axes(xlCategory).TickLabels.Orientation = categoryAngle
    ch.Axes(xlValue).TickLabels.NumberFormat = "0" & K(Array(50613))
    ch.Axes(xlValue).HasMajorGridlines = True
    ch.Axes(xlValue).MajorGridlines.Format.Line.ForeColor.RGB = C_GRID
    ch.Axes(xlValue).HasTitle = False
    On Error GoTo 0
End Sub

Private Function ToEok(ByVal v As Variant) As Double
    If IsNumeric(v) Then
        ToEok = CDbl(v) / 100000000#
    Else
        ToEok = 0#
    End If
End Function

Private Function MaxRowByCol(ByVal ws As Worksheet, ByVal startRow As Long, ByVal endRow As Long, ByVal colLetter As String) As Long
    Dim i As Long, bestRow As Long, bestVal As Double, curVal As Double
    bestRow = startRow
    bestVal = -1E+308
    For i = startRow To endRow
        If IsNumeric(ws.Range(colLetter & i).Value) Then
            curVal = CDbl(ws.Range(colLetter & i).Value)
            If curVal > bestVal Then
                bestVal = curVal
                bestRow = i
            End If
        End If
    Next i
    MaxRowByCol = bestRow
End Function

Private Function MinRowByCol(ByVal ws As Worksheet, ByVal startRow As Long, ByVal endRow As Long, ByVal colLetter As String) As Long
    Dim i As Long, bestRow As Long, bestVal As Double, curVal As Double
    bestRow = startRow
    bestVal = 1E+308
    For i = startRow To endRow
        If IsNumeric(ws.Range(colLetter & i).Value) Then
            curVal = CDbl(ws.Range(colLetter & i).Value)
            If curVal < bestVal Then
                bestVal = curVal
                bestRow = i
            End If
        End If
    Next i
    MinRowByCol = bestRow
End Function

Private Function FmtPctSmart(ByVal v As Variant) As String
    If IsNumeric(v) Then
        If Abs(CDbl(v)) <= 1 Then
            FmtPctSmart = Format(CDbl(v) * 100, "0.00") & "%"
        Else
            FmtPctSmart = Format(CDbl(v), "0.00") & "%"
        End If
    Else
        FmtPctSmart = CStr(v)
    End If
End Function

Private Function FQ(ByVal sheetName As String, ByVal addr As String) As String
    FQ = "'" & Replace(sheetName, "'", "''") & "'!" & addr
End Function

Private Function FxText(ByVal expr As String, ByVal fmt As String) As String
    FxText = "=TEXT(" & expr & ",""" & Replace(fmt, """", """""") & """)"
End Function

Private Function FxNum(ByVal expr As String) As String
    FxNum = FxText(expr, "#,##0")
End Function

Private Function FxEok(ByVal expr As String) As String
    FxEok = "=TEXT((" & expr & ")/100000000,""0.0"")&""" & K(Array(50613, 50896)) & """"
End Function

Private Function FxPct(ByVal expr As String) As String
    FxPct = "=TEXT(IF(ABS(" & expr & ")<=1,(" & expr & ")*100,(" & expr & ")),""0.00"")&""%"""
End Function

Private Function FxCountIfContains(ByVal exprRange As String, ByVal containsText As String) As String
    FxCountIfContains = "=TEXT(COUNTIF(" & exprRange & ",""*"
    FxCountIfContains = FxCountIfContains & Replace(containsText, """", """""")
    FxCountIfContains = FxCountIfContains & "*"") ,""#,##0"")"
End Function

Private Function ShortMonthLabel(ByVal v As Variant) As String
    Dim s As String, parts() As String
    s = Trim(CStr(v))
    If InStr(s, "-") > 0 Then
        parts = Split(s, "-")
        If UBound(parts) >= 1 Then
            ShortMonthLabel = Right$(parts(0), 2) & "-" & parts(1)
            Exit Function
        End If
    End If
    ShortMonthLabel = s
End Function

Private Function ShortQuarterLabel(ByVal v As Variant) As String
    Dim s As String, yy As String, qn As String
    Dim pYear As Long, pQuarter As Long, i As Long, ch As String
    s = Trim(CStr(v))
    pYear = InStr(s, K(Array(45380)))
    pQuarter = InStr(s, K(Array(48516, 44592)))
    If pYear > 2 Then yy = Mid$(s, pYear - 2, 2)
    If pQuarter > 1 Then
        For i = pQuarter - 1 To 1 Step -1
            ch = Mid$(s, i, 1)
            If ch Like "#" Then
                qn = ch
                Exit For
            End If
        Next i
    End If
    If Len(yy) > 0 And Len(qn) > 0 Then
        ShortQuarterLabel = yy & "-" & qn & K(Array(48516, 44592))
    Else
        ShortQuarterLabel = s
    End If
End Function

Private Function QuarterChartLabel(ByVal v As Variant) As String
    Dim baseText As String
    baseText = ShortQuarterLabel(v)
    If InStr(CStr(v), K(Array(50696, 52769))) > 0 Then
        QuarterChartLabel = baseText & " " & K(Array(50696, 52769))
    Else
        QuarterChartLabel = baseText
    End If
End Function

Private Function ChartPctLabel(ByVal v As Variant) As String
    If IsNumeric(v) Then
        If Abs(CDbl(v)) <= 1 Then
            ChartPctLabel = Format(CDbl(v) * 100#, "0.0") & "%"
        Else
            ChartPctLabel = Format(CDbl(v), "0.0") & "%"
        End If
    Else
        ChartPctLabel = CStr(v)
    End If
End Function

Private Sub KPI(ByVal ws As Worksheet, ByVal r As Long, ByVal c As Long, ByVal ttl As String, _
                ByVal f As String, ByVal suffix As String, ByVal accent As Long)
    With ws.Range(ws.Cells(r, c), ws.Cells(r + 3, c + 2))
        .UnMerge
        .Interior.Color = C_PANEL
        .Borders.Color = C_BORDER
        .Borders.Weight = xlThin
    End With
    With ws.Range(ws.Cells(r, c), ws.Cells(r, c + 2))
        .Merge
        .Value = ttl
        .Font.Name = FONT_UI
        .Font.Size = 9
        .Font.Bold = True
        .Font.Color = C_SLATE
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Interior.Color = C_PANEL
    End With
    With ws.Range(ws.Cells(r + 1, c), ws.Cells(r + 2, c + 2))
        .Merge
        .Formula = f
        .Font.Name = FONT_UI
        .Font.Size = 16
        .Font.Bold = True
        .Font.Color = accent
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        If suffix = "%" Then
            .NumberFormat = "0.00""%"""
        Else
            .NumberFormat = "#,##0"
        End If
        .Interior.Color = C_PANEL
    End With
    With ws.Range(ws.Cells(r + 3, c), ws.Cells(r + 3, c + 2))
        .Merge
        .Value = suffix
        .Font.Name = FONT_UI
        .Font.Size = 8
        .Font.Color = C_SLATE
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Interior.Color = C_PANEL
    End With
End Sub

Private Sub PanelTitle(ByVal ws As Worksheet, ByVal rng As Range, ByVal txt As String)
    With rng
        .Merge
        .Value = txt
        .Font.Name = FONT_UI
        .Font.Size = 10
        .Font.Bold = True
        .Font.Color = C_NAVY
        .Interior.Color = C_PANEL
        .HorizontalAlignment = xlLeft
        .VerticalAlignment = xlCenter
    End With
End Sub

Private Sub AddFallbackNote(ByVal ws As Worksheet, ByVal target As Range, ByVal noteText As String)
    With target
        .Merge
        .Value = noteText
        .Font.Name = FONT_UI
        .Font.Size = 9
        .Font.Color = C_SLATE
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Interior.Color = C_PANEL
        .BorderAround xlContinuous, xlThin, , C_BORDER
    End With
End Sub

Private Sub ClearSheetShapes(ByVal ws As Worksheet)
    Dim shp As Shape
    On Error Resume Next
    For Each shp In ws.Shapes
        shp.Delete
    Next shp
    On Error GoTo 0
End Sub

Private Sub PanelFrame(ByVal ws As Worksheet, ByVal outerRange As String, ByVal titleText As String)
    Dim rg As Range
    Dim headerRange As Range
    Set rg = ws.Range(outerRange)
    With rg
        .Interior.Color = C_PANEL
        .Borders.Color = C_BORDER
        .Borders.Weight = xlThin
        .BorderAround xlContinuous, xlThin, , C_BORDER
    End With
    Set headerRange = ws.Range(rg.Cells(1, 1), rg.Cells(1, rg.Columns.Count))
    With headerRange
        .Merge
        .Interior.Color = C_PANEL_TINT
        .Font.Name = FONT_UI
        .Font.Size = 10.5
        .Font.Bold = True
        .Font.Color = C_NAVY
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Value = titleText
    End With
End Sub

Private Sub DashboardCard(ByVal ws As Worksheet, ByVal cardRange As String, ByVal titleText As String, _
                          ByVal formulaText As String, ByVal suffixText As String, _
                          ByVal accentColor As Long, Optional ByVal subText As String = "")
    Dim rg As Range
    Dim cardText As String
    Dim valueStart As Long, suffixStart As Long, subStart As Long
    Set rg = ws.Range(cardRange)
    With rg
        .UnMerge
        .Merge
        .Interior.Color = C_PANEL
        .Borders.Color = C_BORDER
        .Borders.Weight = xlThin
        .VerticalAlignment = xlCenter
        .WrapText = True
        .HorizontalAlignment = xlCenter
    End With

    cardText = titleText & vbLf & vbLf & formulaText
    valueStart = Len(titleText) + 3
    If Len(suffixText) > 0 Then
        suffixStart = Len(cardText) + 2
        cardText = cardText & vbLf & suffixText
    End If
    If Len(subText) > 0 Then
        subStart = Len(cardText) + 2
        cardText = cardText & vbLf & subText
    End If

    With rg
        .Value = cardText
        .Font.Name = FONT_UI
        .Font.Size = 8
        .Font.Color = C_SLATE
        .HorizontalAlignment = xlCenter
    End With

    With rg.Characters(valueStart, Len(formulaText))
        .Font.Size = 16
        .Font.Bold = True
        .Font.Color = accentColor
    End With

    If suffixStart > 0 Then
        With rg.Characters(suffixStart, Len(suffixText))
            .Font.Size = 8
            .Font.Bold = False
            .Font.Color = C_SLATE
        End With
    End If

    If subStart > 0 Then
        With rg.Characters(subStart, Len(subText))
            .Font.Size = 8
            .Font.Bold = False
            .Font.Color = C_SLATE
        End With
    End If
End Sub

Private Sub DashboardFormulaCard(ByVal ws As Worksheet, ByVal cardRange As String, ByVal titleText As String, _
                                 ByVal valueFormula As String, ByVal suffixText As String, _
                                 ByVal accentColor As Long)
    Dim rg As Range
    Dim titleRg As Range, valueRg As Range, suffixRg As Range
    Set rg = ws.Range(cardRange)

    rg.UnMerge
    rg.Interior.Color = C_PANEL
    rg.Borders.Color = C_BORDER
    rg.Borders.Weight = xlThin
    rg.BorderAround xlContinuous, xlThin, , C_BORDER

    Set titleRg = ws.Range(rg.Cells(1, 1), rg.Cells(1, rg.Columns.Count))
    Set valueRg = ws.Range(rg.Cells(2, 1), rg.Cells(rg.Rows.Count - 1, rg.Columns.Count))
    Set suffixRg = ws.Range(rg.Cells(rg.Rows.Count, 1), rg.Cells(rg.Rows.Count, rg.Columns.Count))

    With titleRg
        .Merge
        .Value = titleText
        .Font.Name = FONT_UI
        .Font.Size = 8.5
        .Font.Bold = True
        .Font.Color = C_SLATE
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Interior.Color = C_PANEL_SOFT
    End With

    With valueRg
        .Merge
        .Formula = valueFormula
        .Font.Name = FONT_UI
        .Font.Size = 18
        .Font.Bold = True
        .Font.Color = accentColor
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Interior.Color = C_PANEL
    End With

    With suffixRg
        .Merge
        .Value = suffixText
        .Font.Name = FONT_UI
        .Font.Size = 8
        .Font.Bold = False
        .Font.Color = C_SLATE
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Interior.Color = C_PANEL_SOFT
    End With
End Sub

Private Sub MetricList(ByVal ws As Worksheet, ByVal topLeft As String, ByVal titleText As String, _
                       ByVal labels As Variant, ByVal vals As Variant, _
                       Optional ByVal formats As Variant)
    Dim startCell As Range
    Dim i As Long
    Dim rowIndex As Long
    Set startCell = ws.Range(topLeft)

    With ws.Range(startCell, startCell.Offset(0, 3))
        .Merge
        .Value = titleText
        .Font.Name = FONT_UI
        .Font.Size = 10.5
        .Font.Bold = True
        .Font.Color = C_NAVY
        .Interior.Color = C_PANEL_TINT
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Borders.Color = C_BORDER
    End With

    For i = LBound(labels) To UBound(labels)
        rowIndex = startCell.Row + 1 + i
        With ws.Range(ws.Cells(rowIndex, startCell.Column), ws.Cells(rowIndex, startCell.Column + 1))
            .Merge
            .Value = labels(i)
            .Font.Name = FONT_UI
            .Font.Size = 8.5
            .Font.Color = C_SLATE
            .Interior.Color = C_PANEL_SOFT
            .HorizontalAlignment = xlLeft
            .VerticalAlignment = xlCenter
            .Borders.Color = C_BORDER
        End With
        With ws.Range(ws.Cells(rowIndex, startCell.Column + 2), ws.Cells(rowIndex, startCell.Column + 3))
            .Merge
            If VarType(vals(i)) = vbString And Left$(CStr(vals(i)), 1) = "=" Then
                .Formula = vals(i)
            Else
                .Value = vals(i)
            End If
            .Font.Name = FONT_UI
            .Font.Size = 10
            .Font.Bold = True
            .Font.Color = C_NAVY
            .Interior.Color = C_PANEL
            .HorizontalAlignment = xlRight
            .VerticalAlignment = xlCenter
            .Borders.Color = C_BORDER
            If Not IsMissing(formats) Then
                On Error Resume Next
                .NumberFormat = formats(i)
                On Error GoTo 0
            End If
        End With
    Next i
End Sub

Private Sub BuildMonthlySummary(ByVal db As Worksheet, ByVal mm As Worksheet, ByVal sm As Worksheet, ByVal lr As Long)
    Dim labels As Variant, vals As Variant, fmts As Variant
    labels = Array( _
        K(Array(52572, 44540, 32, 50900)), _
        K(Array(52572, 44540, 32, 47588, 52636)), _
        K(Array(52572, 44540, 32, 51060, 51061)), _
        K(Array(52572, 45824, 32, 55121, 51088, 50900)), _
        K(Array(52572, 45824, 32, 51201, 51088, 50900)), _
        K(Array(51204, 52404, 32, 54217, 44512, 32, 51060, 51061, 47456)), _
        K(Array(52509, 32, 49688, 51452, 44148, 49688)), _
        K(Array(45572, 51201, 32, 47588, 52636)), _
        K(Array(45572, 51201, 32, 51060, 51061)), _
        K(Array(54217, 44512, 32, 49688, 51452, 44552, 50529)) _
    )
    vals = Array( _
        "=" & FQ(mm.Name, "A" & lr), _
        FxEok(FQ(mm.Name, "B" & lr)), _
        FxEok(FQ(mm.Name, "D" & lr)), _
        "=INDEX(" & FQ(mm.Name, "A3:A" & lr) & ",MATCH(MAX(" & FQ(mm.Name, "D3:D" & lr) & ")," & FQ(mm.Name, "D3:D" & lr) & ",0))", _
        "=INDEX(" & FQ(mm.Name, "A3:A" & lr) & ",MATCH(MIN(" & FQ(mm.Name, "D3:D" & lr) & ")," & FQ(mm.Name, "D3:D" & lr) & ",0))", _
        FxPct("AVERAGE(" & FQ(mm.Name, "E3:E" & lr) & ")"), _
        FxNum(FQ(sm.Name, "B10")), _
        FxEok("SUM(" & FQ(mm.Name, "B3:B" & lr) & ")"), _
        FxEok("SUM(" & FQ(mm.Name, "D3:D" & lr) & ")"), _
        FxEok(FQ(sm.Name, "B11")) _
    )
    fmts = Array("@", "@", "@", "@", "@", "@", "@", "@", "@", "@")
    MetricList db, "T14", K(Array(54645, 49900, 32, 50836, 50557)), labels, vals, fmts
End Sub

Private Sub BuildQuarterlySummary(ByVal db As Worksheet, ByVal qt As Worksheet, ByVal sm As Worksheet, ByVal lr As Long)
    Dim labels As Variant, vals As Variant, fmts As Variant
    labels = Array( _
        K(Array(52572, 44540, 32, 48516, 44592)), _
        K(Array(52572, 44540, 32, 47588, 52636)), _
        K(Array(52572, 44540, 32, 51060, 51061)), _
        K(Array(52572, 45824, 32, 55121, 51088, 32, 48516, 44592)), _
        K(Array(52572, 45824, 32, 51201, 51088, 32, 48516, 44592)), _
        K(Array(54217, 44512, 32, 51060, 51061, 47456)), _
        K(Array(52509, 32, 49688, 51452, 44148, 49688)), _
        K(Array(45572, 51201, 32, 47588, 52636)), _
        K(Array(45572, 51201, 32, 51060, 51061)), _
        K(Array(50696, 52769, 32, 48516, 44592, 32, 49688)) _
    )
    vals = Array( _
        "=" & FQ(qt.Name, "A" & lr), _
        FxEok(FQ(qt.Name, "B" & lr)), _
        FxEok(FQ(qt.Name, "D" & lr)), _
        "=INDEX(" & FQ(qt.Name, "A3:A" & lr) & ",MATCH(MAX(" & FQ(qt.Name, "D3:D" & lr) & ")," & FQ(qt.Name, "D3:D" & lr) & ",0))", _
        "=INDEX(" & FQ(qt.Name, "A3:A" & lr) & ",MATCH(MIN(" & FQ(qt.Name, "D3:D" & lr) & ")," & FQ(qt.Name, "D3:D" & lr) & ",0))", _
        FxPct("AVERAGE(" & FQ(qt.Name, "E3:E" & lr) & ")"), _
        FxNum(FQ(sm.Name, "B10")), _
        FxEok("SUM(" & FQ(qt.Name, "B3:B" & lr) & ")"), _
        FxEok("SUM(" & FQ(qt.Name, "D3:D" & lr) & ")"), _
        FxCountIfContains(FQ(qt.Name, "A3:A" & lr), K(Array(50696, 52769))) _
    )
    fmts = Array("@", "@", "@", "@", "@", "@", "@", "@", "@", "@")
    MetricList db, "T33", K(Array(48516, 44592, 32, 50836, 50557)), labels, vals, fmts
End Sub

Private Sub BuildForecastSummary(ByVal db As Worksheet, ByVal fc As Worksheet, ByVal lr As Long)
    Dim labels As Variant, vals As Variant, fmts As Variant
    labels = Array( _
        K(Array(50696, 52769, 32, 44592, 51456, 50900)), _
        K(Array(50696, 52769, 32, 47588, 52636)), _
        K(Array(50696, 52769, 32, 51060, 51061)), _
        K(Array(52572, 45824, 32, 50696, 52769, 32, 50900)), _
        K(Array(52572, 49548, 32, 50696, 52769, 32, 50900)), _
        K(Array(54217, 44512, 32, 51060, 51061, 47456)), _
        K(Array(45572, 51201, 32, 50696, 49345, 32, 47588, 52636)), _
        K(Array(45572, 51201, 32, 50696, 49345, 32, 51060, 51061)), _
        K(Array(52395, 32, 50696, 52769, 32, 50900)), _
        K(Array(47560, 51648, 47561, 32, 50900)) _
    )
    vals = Array( _
        "=" & FQ(fc.Name, "A" & lr), _
        FxEok(FQ(fc.Name, "B" & lr)), _
        FxEok(FQ(fc.Name, "D" & lr)), _
        "=INDEX(" & FQ(fc.Name, "A3:A" & lr) & ",MATCH(MAX(" & FQ(fc.Name, "B3:B" & lr) & ")," & FQ(fc.Name, "B3:B" & lr) & ",0))", _
        "=INDEX(" & FQ(fc.Name, "A3:A" & lr) & ",MATCH(MIN(" & FQ(fc.Name, "B3:B" & lr) & ")," & FQ(fc.Name, "B3:B" & lr) & ",0))", _
        FxPct("AVERAGE(" & FQ(fc.Name, "E3:E" & lr) & ")"), _
        FxEok("SUM(" & FQ(fc.Name, "B3:B" & lr) & ")"), _
        FxEok("SUM(" & FQ(fc.Name, "D3:D" & lr) & ")"), _
        "=" & FQ(fc.Name, "A3"), _
        "=" & FQ(fc.Name, "A" & lr) _
    )
    fmts = Array("@", "@", "@", "@", "@", "@", "@", "@", "@", "@")
    MetricList db, "T52", K(Array(50696, 52769, 32, 50836, 50557)), labels, vals, fmts
End Sub

Private Sub BuildQualitySummary(ByVal db As Worksheet, ByVal ql As Worksheet)
    Dim labels As Variant, vals As Variant, fmts As Variant
    labels = Array( _
        K(Array(50577, 54408, 32, 49688, 47049)), _
        K(Array(48520, 47049, 32, 49688, 47049)), _
        K(Array(49688, 50984)), _
        K(Array(44592, 54924, 48708, 50857)) _
    )
    vals = Array( _
        FxNum(FQ(ql.Name, "B3")), _
        FxNum(FQ(ql.Name, "B4")), _
        FxPct(FQ(ql.Name, "C6")), _
        FxEok(FQ(ql.Name, "B7")) _
    )
    fmts = Array("#,##0", "#,##0", "@", "@")
    MetricList db, "T70", K(Array(54408, 51656, 32, 50836, 50557)), labels, vals, fmts
End Sub

Private Sub BuildCancelSummary(ByVal db As Worksheet, ByVal cc As Worksheet)
    Dim labels As Variant, vals As Variant, fmts As Variant
    labels = Array( _
        K(Array(52712, 49548, 50984)), _
        K(Array(52712, 49548, 32, 49688, 51452)), _
        K(Array(51221, 49345, 32, 49688, 51452)), _
        K(Array(49552, 49892, 50529)) _
    )
    vals = Array( _
        FxPct(FQ(cc.Name, "C7")), _
        FxNum(FQ(cc.Name, "B5")), _
        FxNum(FQ(cc.Name, "B4")), _
        FxEok(FQ(cc.Name, "B6")) _
    )
    fmts = Array("@", "#,##0", "#,##0", "@")
    MetricList db, "T75", K(Array(52712, 49548, 32, 50836, 50557)), labels, vals, fmts
End Sub

Private Function FmtEokText(ByVal v As Variant) As String
    If IsNumeric(v) Then
        FmtEokText = Format(CDbl(v) / 100000000#, "0.0") & K(Array(50613, 50896))
    Else
        FmtEokText = CStr(v)
    End If
End Function

Private Sub CopyChartToRange(ByVal srcWs As Worksheet, ByVal chartIndex As Long, ByVal dstWs As Worksheet, ByVal targetRange As String)
    Dim rg As Range
    Dim pad As Double
    pad = 6
    Set rg = dstWs.Range(targetRange)
    If Not CopyChartPicture(srcWs, chartIndex, dstWs, rg.Left + pad, rg.Top + pad, rg.Width - (pad * 2), rg.Height - (pad * 2)) Then
        AddFallbackNote dstWs, rg, K(Array(52264, 53944, 47484, 32, 54364, 49884, 44032, 32, 50506, 49845, 49884, 45796))
    End If
End Sub

Private Function EnsureHelperSheet() As Worksheet
    Set EnsureHelperSheet = GetWS(S_Helper())
    If EnsureHelperSheet Is Nothing Then
        Set EnsureHelperSheet = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        EnsureHelperSheet.Name = S_Helper()
    End If
    EnsureHelperSheet.Visible = xlSheetVeryHidden
End Function

Private Sub PrepareMonthlyDashboardHelper(ByVal hp As Worksheet, ByVal mm As Worksheet, ByVal lr As Long)
    Dim i As Long, r As Long
    hp.Range("A1:D200").ClearContents
    hp.Range("A1:D1").Value = Array(mm.Range("A2").Value, mm.Range("B2").Value, mm.Range("C2").Value, mm.Range("E2").Value)
    r = 2
    For i = 3 To lr
        hp.Cells(r, 1).Value = ShortMonthLabel(mm.Cells(i, 1).Value)
        hp.Cells(r, 2).Formula = "=" & FQ(mm.Name, "B" & i) & "/100000000"
        hp.Cells(r, 3).Formula = "=" & FQ(mm.Name, "C" & i) & "/100000000"
        hp.Cells(r, 4).Formula = "=" & FQ(mm.Name, "E" & i)
        r = r + 1
    Next i
End Sub

Private Sub CreateDashboardMonthlyLiveChart(ByVal db As Worksheet, ByVal mm As Worksheet, ByVal targetRange As String)
    Dim hp As Worksheet
    Dim rg As Range
    Dim co As ChartObject
    Dim lr As Long
    Dim pad As Double

    lr = LastDataRow(mm, "A")
    If lr < 3 Then Exit Sub

    Set hp = EnsureHelperSheet()
    PrepareMonthlyDashboardHelper hp, mm, lr

    Set rg = db.Range(targetRange)
    pad = 6
    Set co = db.ChartObjects.Add(rg.Left + pad, rg.Top + pad, rg.Width - (pad * 2), rg.Height - (pad * 2))

    With co.Chart
        .ChartType = xlColumnClustered
        .SeriesCollection.NewSeries
        .SeriesCollection(1).Values = hp.Range("B2:B" & (lr - 1))
        .SeriesCollection(1).XValues = hp.Range("A2:A" & (lr - 1))
        .SeriesCollection(1).Name = hp.Range("B1").Value

        .SeriesCollection.NewSeries
        .SeriesCollection(2).Values = hp.Range("C2:C" & (lr - 1))
        .SeriesCollection(2).XValues = hp.Range("A2:A" & (lr - 1))
        .SeriesCollection(2).Name = hp.Range("C1").Value

        .SeriesCollection.NewSeries
        .SeriesCollection(3).Values = hp.Range("D2:D" & (lr - 1))
        .SeriesCollection(3).XValues = hp.Range("A2:A" & (lr - 1))
        .SeriesCollection(3).Name = hp.Range("D1").Value
        .SeriesCollection(3).ChartType = xlLineMarkers
        .SeriesCollection(3).AxisGroup = xlSecondary

        .SeriesCollection(1).Format.Fill.ForeColor.RGB = C_NAVY
        .SeriesCollection(2).Format.Fill.ForeColor.RGB = C_STEEL
        .SeriesCollection(3).Format.Line.ForeColor.RGB = C_GREEN
        .SeriesCollection(3).Format.Line.Weight = 1.75
        .SeriesCollection(3).MarkerForegroundColor = C_GREEN
        .SeriesCollection(3).MarkerBackgroundColor = C_PANEL
        .SeriesCollection(3).MarkerSize = 6

        ChartSkin co.Chart, T_Monthly()
        ApplyKrwAxis co.Chart, 3, 45
        .ChartGroups(1).GapWidth = 55

        On Error Resume Next
        .Axes(xlValue, xlSecondary).TickLabels.NumberFormat = "0%"
        .Axes(xlValue, xlSecondary).MaximumScale = 20
        .Axes(xlValue, xlSecondary).MinimumScale = -20
        On Error GoTo 0
    End With
End Sub

Private Sub PrepareQuarterlyDashboardHelper(ByVal hp As Worksheet, ByVal qt As Worksheet, ByVal lr As Long)
    Dim i As Long, r As Long
    hp.Range("AF1:AJ200").ClearContents
    hp.Range("AF1:AJ1").Value = Array(qt.Range("A2").Value, qt.Range("B2").Value, qt.Range("D2").Value, qt.Range("E2").Value, "is_fc")
    r = 2
    For i = 3 To lr
        hp.Cells(r, 32).Value = QuarterChartLabel(qt.Cells(i, 1).Value)
        hp.Cells(r, 33).Formula = "=" & FQ(qt.Name, "B" & i) & "/100000000"
        hp.Cells(r, 34).Formula = "=" & FQ(qt.Name, "D" & i) & "/100000000"
        hp.Cells(r, 35).Formula = "=" & FQ(qt.Name, "E" & i)
        hp.Cells(r, 36).Value = IIf(InStr(CStr(qt.Cells(i, 1).Value), K(Array(50696, 52769))) > 0, 1, 0)
        r = r + 1
    Next i
End Sub

Private Sub CreateDashboardQuarterlyLiveChart(ByVal db As Worksheet, ByVal qt As Worksheet, ByVal targetRange As String)
    Dim hp As Worksheet
    Dim rg As Range
    Dim co As ChartObject
    Dim lr As Long
    Dim pad As Double
    Dim p As Long

    lr = LastDataRow(qt, "A")
    If lr < 3 Then Exit Sub

    Set hp = EnsureHelperSheet()
    PrepareQuarterlyDashboardHelper hp, qt, lr

    Set rg = db.Range(targetRange)
    pad = 6
    Set co = db.ChartObjects.Add(rg.Left + pad, rg.Top + pad, rg.Width - (pad * 2), rg.Height - (pad * 2))

    With co.Chart
        .ChartType = xlColumnClustered
        .SeriesCollection.NewSeries
        .SeriesCollection(1).Values = hp.Range("AG2:AG" & (lr - 1))
        .SeriesCollection(1).XValues = hp.Range("AF2:AF" & (lr - 1))
        .SeriesCollection(1).Name = hp.Range("AG1").Value

        .SeriesCollection.NewSeries
        .SeriesCollection(2).Values = hp.Range("AH2:AH" & (lr - 1))
        .SeriesCollection(2).XValues = hp.Range("AF2:AF" & (lr - 1))
        .SeriesCollection(2).Name = hp.Range("AH1").Value

        .SeriesCollection.NewSeries
        .SeriesCollection(3).Values = hp.Range("AI2:AI" & (lr - 1))
        .SeriesCollection(3).XValues = hp.Range("AF2:AF" & (lr - 1))
        .SeriesCollection(3).Name = hp.Range("AI1").Value
        .SeriesCollection(3).ChartType = xlLineMarkers
        .SeriesCollection(3).AxisGroup = xlSecondary

        .SeriesCollection(1).Format.Fill.ForeColor.RGB = C_NAVY
        .SeriesCollection(2).Format.Fill.ForeColor.RGB = C_STEEL
        .SeriesCollection(3).Format.Line.ForeColor.RGB = C_GREEN
        .SeriesCollection(3).Format.Line.Weight = 1.75
        .SeriesCollection(3).MarkerForegroundColor = C_GREEN
        .SeriesCollection(3).MarkerBackgroundColor = C_PANEL
        .SeriesCollection(3).MarkerSize = 6

        For p = 1 To (lr - 2)
            If hp.Cells(p + 1, 36).Value = 1 Then
                .SeriesCollection(1).Points(p).Format.Fill.ForeColor.RGB = C_GREEN
                .SeriesCollection(2).Points(p).Format.Fill.ForeColor.RGB = C_PANEL_TINT
            End If
        Next p

        ChartSkin co.Chart, T_Quarterly()
        ApplyKrwAxis co.Chart, 1, 35
        .ChartGroups(1).GapWidth = 65

        On Error Resume Next
        .Axes(xlValue, xlSecondary).TickLabels.NumberFormat = "0%"
        .Axes(xlValue, xlSecondary).MaximumScale = 20
        .Axes(xlValue, xlSecondary).MinimumScale = -10
        On Error GoTo 0
    End With
End Sub

Private Sub PrepareForecastDashboardHelper(ByVal hp As Worksheet, ByVal fc As Worksheet, ByVal lr As Long)
    Dim i As Long, r As Long
    hp.Range("AK1:AM200").ClearContents
    hp.Range("AK1:AM1").Value = Array(fc.Range("A2").Value, fc.Range("B2").Value, fc.Range("D2").Value)
    r = 2
    For i = 3 To lr
        hp.Cells(r, 37).Value = ShortMonthLabel(fc.Cells(i, 1).Value)
        hp.Cells(r, 38).Formula = "=" & FQ(fc.Name, "B" & i) & "/100000000"
        hp.Cells(r, 39).Formula = "=" & FQ(fc.Name, "D" & i) & "/100000000"
        r = r + 1
    Next i
End Sub

Private Sub CreateDashboardForecastLiveChart(ByVal db As Worksheet, ByVal fc As Worksheet, ByVal targetRange As String)
    Dim hp As Worksheet
    Dim rg As Range
    Dim co As ChartObject
    Dim lr As Long
    Dim pad As Double
    Dim lastIdx As Long

    lr = LastDataRow(fc, "A")
    If lr < 3 Then Exit Sub

    Set hp = EnsureHelperSheet()
    PrepareForecastDashboardHelper hp, fc, lr

    Set rg = db.Range(targetRange)
    pad = 6
    Set co = db.ChartObjects.Add(rg.Left + pad, rg.Top + pad, rg.Width - (pad * 2), rg.Height - (pad * 2))
    lastIdx = lr - 2

    With co.Chart
        .ChartType = xlLineMarkers
        .SeriesCollection.NewSeries
        .SeriesCollection(1).Values = hp.Range("AL2:AL" & (lr - 1))
        .SeriesCollection(1).XValues = hp.Range("AK2:AK" & (lr - 1))
        .SeriesCollection(1).Name = hp.Range("AL1").Value

        .SeriesCollection.NewSeries
        .SeriesCollection(2).Values = hp.Range("AM2:AM" & (lr - 1))
        .SeriesCollection(2).XValues = hp.Range("AK2:AK" & (lr - 1))
        .SeriesCollection(2).Name = hp.Range("AM1").Value
        .SeriesCollection(2).ChartType = xlLineMarkers

        .SeriesCollection(1).Format.Line.ForeColor.RGB = C_NAVY
        .SeriesCollection(1).Format.Line.Weight = 2.25
        .SeriesCollection(1).MarkerForegroundColor = C_NAVY
        .SeriesCollection(1).MarkerBackgroundColor = C_PANEL
        .SeriesCollection(1).MarkerSize = 6
        .SeriesCollection(1).Smooth = True
        .SeriesCollection(2).Format.Line.ForeColor.RGB = C_GREEN
        .SeriesCollection(2).Format.Line.Weight = 1.75
        .SeriesCollection(2).MarkerForegroundColor = C_GREEN
        .SeriesCollection(2).MarkerBackgroundColor = C_PANEL
        .SeriesCollection(2).MarkerSize = 6
        .SeriesCollection(2).Smooth = True

        On Error Resume Next
        .SeriesCollection(1).Trendlines.Add
        .SeriesCollection(1).Trendlines(1).Format.Line.ForeColor.RGB = C_STEEL
        .SeriesCollection(1).Trendlines(1).Format.Line.Weight = 1
        .SeriesCollection(1).Points(lastIdx).HasDataLabel = True
        .SeriesCollection(1).Points(lastIdx).DataLabel.Text = Format(hp.Range("AL" & (lr - 1)).Value, "0.0") & K(Array(50613, 50896))
        .SeriesCollection(2).Points(lastIdx).HasDataLabel = True
        .SeriesCollection(2).Points(lastIdx).DataLabel.Text = Format(hp.Range("AM" & (lr - 1)).Value, "0.0") & K(Array(50613, 50896))
        .SeriesCollection(1).Points(lastIdx).DataLabel.Font.Name = FONT_UI
        .SeriesCollection(1).Points(lastIdx).DataLabel.Font.Size = 8
        .SeriesCollection(2).Points(lastIdx).DataLabel.Font.Name = FONT_UI
        .SeriesCollection(2).Points(lastIdx).DataLabel.Font.Size = 8
        On Error GoTo 0

        ChartSkin co.Chart, T_Forecast()
        ApplyKrwAxis co.Chart, 2, 0
    End With
End Sub

Private Sub PrepareQualityDashboardHelper(ByVal hp As Worksheet, ByVal ql As Worksheet)
    hp.Range("AO1:AP3").ClearContents
    hp.Range("AO1:AP1").Value = Array(ql.Range("A2").Value, ql.Range("B2").Value)
    hp.Range("AO2").Formula = "=" & FQ(ql.Name, "A3")
    hp.Range("AP2").Formula = "=" & FQ(ql.Name, "B3")
    hp.Range("AO3").Formula = "=" & FQ(ql.Name, "A4")
    hp.Range("AP3").Formula = "=" & FQ(ql.Name, "B4")
End Sub

Private Sub CreateDashboardQualityLiveChart(ByVal db As Worksheet, ByVal ql As Worksheet, ByVal targetRange As String)
    Dim hp As Worksheet
    Dim rg As Range
    Dim co As ChartObject
    Dim pad As Double

    Set hp = EnsureHelperSheet()
    PrepareQualityDashboardHelper hp, ql
    Set rg = db.Range(targetRange)
    pad = 6
    Set co = db.ChartObjects.Add(rg.Left + pad, rg.Top + pad, rg.Width - (pad * 2), rg.Height - (pad * 2))
    With co.Chart
        .ChartType = xlDoughnut
        .SetSourceData hp.Range("AO2:AP3")
        .SeriesCollection(1).Points(1).Format.Fill.ForeColor.RGB = C_STEEL
        .SeriesCollection(1).Points(2).Format.Fill.ForeColor.RGB = C_GREEN
        On Error Resume Next
        .DoughnutGroups(1).DoughnutHoleSize = 70
        .SeriesCollection(1).Points(1).Format.Line.Visible = msoTrue
        .SeriesCollection(1).Points(1).Format.Line.ForeColor.RGB = C_NAVY_DARK
        .SeriesCollection(1).Points(1).Format.Line.Weight = 1.2
        .SeriesCollection(1).Points(2).Format.Line.Visible = msoTrue
        .SeriesCollection(1).Points(2).Format.Line.ForeColor.RGB = RGB(56, 100, 86)
        .SeriesCollection(1).Points(2).Format.Line.Weight = 1.2
        .SeriesCollection(1).Points(1).Explosion = 3
        .SeriesCollection(1).Points(2).Explosion = 12
        .HasLegend = False
        .SeriesCollection(1).HasDataLabels = False
        On Error GoTo 0
        ChartSkin co.Chart, T_Quality(), False
    End With
    AddDonutCallouts db, co, "quality_dash", _
                     K(Array(48520, 47049)) & " " & FmtNum(ql.Range("B4").Value) & " (" & PctDisplay(ql.Range("C4").Value) & ")", RGB(56, 100, 86), _
                     K(Array(50577, 54408)) & " " & FmtNum(ql.Range("B3").Value) & " (" & PctDisplay(ql.Range("C3").Value) & ")", C_NAVY
End Sub

Private Sub PrepareCancelDashboardHelper(ByVal hp As Worksheet, ByVal cc As Worksheet)
    hp.Range("AR1:AT3").ClearContents
    hp.Range("AR1:AT1").Value = Array(K(Array(44396, 48516)), K(Array(44148, 49688)), K(Array(48708, 51473, 47456)))
    hp.Range("AR2").Value = K(Array(51221, 49345))
    hp.Range("AS2").Formula = "=" & FQ(cc.Name, "B4")
    hp.Range("AT2").Formula = "=" & FQ(cc.Name, "C4")
    hp.Range("AR3").Value = K(Array(52712, 49548))
    hp.Range("AS3").Formula = "=" & FQ(cc.Name, "B5")
    hp.Range("AT3").Formula = "=" & FQ(cc.Name, "C5")
End Sub

Private Sub CreateDashboardCancelLiveChart(ByVal db As Worksheet, ByVal cc As Worksheet, ByVal targetRange As String)
    Dim hp As Worksheet
    Dim rg As Range
    Dim co As ChartObject
    Dim pad As Double

    Set hp = EnsureHelperSheet()
    PrepareCancelDashboardHelper hp, cc
    Set rg = db.Range(targetRange)
    pad = 6
    Set co = db.ChartObjects.Add(rg.Left + pad, rg.Top + pad, rg.Width - (pad * 2), rg.Height - (pad * 2))

    With co.Chart
        .ChartType = xlDoughnut
        .SetSourceData hp.Range("AR2:AS3")
        .SeriesCollection(1).Points(1).Format.Fill.ForeColor.RGB = C_STEEL
        .SeriesCollection(1).Points(2).Format.Fill.ForeColor.RGB = C_AMBER
        On Error Resume Next
        .DoughnutGroups(1).DoughnutHoleSize = 70
        .SeriesCollection(1).Points(1).Format.Line.Visible = msoTrue
        .SeriesCollection(1).Points(1).Format.Line.ForeColor.RGB = C_NAVY_DARK
        .SeriesCollection(1).Points(1).Format.Line.Weight = 1.2
        .SeriesCollection(1).Points(2).Format.Line.Visible = msoTrue
        .SeriesCollection(1).Points(2).Format.Line.ForeColor.RGB = RGB(138, 92, 56)
        .SeriesCollection(1).Points(2).Format.Line.Weight = 1.2
        .SeriesCollection(1).Points(1).Explosion = 3
        .SeriesCollection(1).Points(2).Explosion = 12
        .HasLegend = False
        .SeriesCollection(1).HasDataLabels = False
        On Error GoTo 0
        ChartSkin co.Chart, T_Cancel(), False
    End With
    AddDonutCallouts db, co, "cancel_dash", _
                     K(Array(52712, 49548)) & " " & FmtNum(cc.Range("B5").Value) & " (" & PctDisplay(cc.Range("C5").Value) & ")", RGB(138, 92, 56), _
                     K(Array(51221, 49345)) & " " & FmtNum(cc.Range("B4").Value) & " (" & PctDisplay(cc.Range("C4").Value) & ")", C_NAVY
End Sub

Private Sub SetCellBlock(ByVal target As Range, ByVal val As Variant, _
                         Optional ByVal fontSize As Double = 9, _
                         Optional ByVal isBold As Boolean = False, _
                         Optional ByVal fontColor As Long = -1, _
                         Optional ByVal fillColor As Long = -1, _
                         Optional ByVal hAlign As XlHAlign = xlCenter)
    target.Value = val
    target.Font.Name = FONT_UI
    target.Font.Size = fontSize
    target.Font.Bold = isBold
    If fontColor <> -1 Then target.Font.Color = fontColor
    If fillColor <> -1 Then target.Interior.Color = fillColor
    target.HorizontalAlignment = hAlign
    target.VerticalAlignment = xlCenter
    target.Borders.Color = C_BORDER
End Sub

Private Function CopyChartPicture(ByVal srcWs As Worksheet, ByVal chartIndex As Long, _
                                  ByVal dstWs As Worksheet, ByVal leftPos As Double, _
                                  ByVal topPos As Double, ByVal widthVal As Double, _
                                  ByVal heightVal As Double) As Boolean
    Dim shp As Shape
    On Error GoTo Fail
    srcWs.ChartObjects(chartIndex).CopyPicture Appearance:=xlScreen, Format:=xlPicture
    dstWs.Paste
    Set shp = dstWs.Shapes(dstWs.Shapes.Count)
    shp.Left = leftPos
    shp.Top = topPos
    shp.Width = widthVal
    shp.Height = heightVal
    CopyChartPicture = True
    Exit Function
Fail:
    CopyChartPicture = False
End Function

Private Function FmtNum(ByVal v As Variant) As String
    If IsNumeric(v) Then
        FmtNum = Format(v, "#,##0")
    Else
        FmtNum = CStr(v)
    End If
End Function

Private Function FmtPct(ByVal v As Variant) As String
    If IsNumeric(v) Then
        FmtPct = Format(v, "0.00") & "%"
    Else
        FmtPct = CStr(v)
    End If
End Function

Private Function PctDisplay(ByVal v As Variant) As String
    If IsNumeric(v) Then
        If Abs(CDbl(v)) <= 1 Then
            PctDisplay = CStr(Format(CDbl(v) * 100#, "0.00")) & "%"
        Else
            PctDisplay = CStr(Format(CDbl(v), "0.00")) & "%"
        End If
    Else
        PctDisplay = CStr(v)
    End If
End Function

Private Sub SummaryTable(ByVal ws As Worksheet, ByVal topLeft As String, ByVal titleText As String, _
                         ByVal headers As Variant, ByVal values As Variant, ByVal panelCols As Long)
    Dim startCell As Range, titleRange As Range, headRange As Range, bodyRange As Range
    Dim i As Long, r As Long, c As Long
    Set startCell = ws.Range(topLeft)
    Set titleRange = ws.Range(startCell, startCell.Offset(0, panelCols - 1))
    Set headRange = ws.Range(startCell.Offset(1, 0), startCell.Offset(1, panelCols - 1))
    Set bodyRange = ws.Range(startCell.Offset(2, 0), startCell.Offset(UBound(values) + 2, panelCols - 1))

    With titleRange
        .Merge
        .Value = titleText
        .Font.Name = FONT_UI
        .Font.Size = 10
        .Font.Bold = True
        .Font.Color = C_NAVY
        .Interior.Color = C_PANEL
        .HorizontalAlignment = xlLeft
        .VerticalAlignment = xlCenter
        .Borders.Color = C_BORDER
    End With
    With headRange
        .Font.Name = FONT_UI
        .Font.Size = 8.5
        .Font.Bold = True
        .Font.Color = C_SLATE
        .Interior.Color = RGB(246, 248, 251)
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Borders.Color = C_BORDER
    End With
    With bodyRange
        .Font.Name = FONT_UI
        .Font.Size = 9
        .Interior.Color = C_PANEL
        .Borders.Color = C_BORDER
        .VerticalAlignment = xlCenter
    End With
    For c = 0 To panelCols - 1
        headRange.Cells(1, c + 1).Value = headers(c)
    Next c
    For r = 0 To UBound(values)
        For c = 0 To panelCols - 1
            bodyRange.Cells(r + 1, c + 1).Value = values(r)(c)
        Next c
    Next r
    For i = 1 To panelCols
        ws.Columns(startCell.Column + i - 1).ColumnWidth = ws.Columns(startCell.Column + i - 1).ColumnWidth
    Next i
End Sub

Sub Auto_Open(): Create_Run_Button: End Sub

Sub Create_Run_Button()
    Dim ws As Worksheet, runBtn As Shape, resetBtn As Shape
    Set ws = GetWS(S_Summary())
    If ws Is Nothing Then Exit Sub
    On Error Resume Next
    ws.Shapes("btn_run").Delete
    ws.Shapes("btn_reset").Delete
    On Error GoTo 0
    Set runBtn = ws.Shapes.AddShape(msoShapeRoundedRectangle, ws.Range("A1").Left + 4, ws.Range("A1").Top + 4, ws.Range("A1:D2").Width - 8, ws.Range("A1:D2").Height - 8)
    With runBtn
        .Name = "btn_run"
        .TextFrame2.TextRange.Text = T_Run()
        .TextFrame2.TextRange.Font.Name = FONT_UI
        .TextFrame2.TextRange.Font.Size = 11
        .TextFrame2.TextRange.Font.Bold = msoTrue
        .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = C_PANEL
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
        .TextFrame2.VerticalAnchor = msoAnchorMiddle
        .Fill.ForeColor.RGB = C_NAVY
        .Line.ForeColor.RGB = C_NAVY_DARK
        .OnAction = "Run_All_Reports"
    End With
    Set resetBtn = ws.Shapes.AddShape(msoShapeRoundedRectangle, ws.Range("F1").Left, ws.Range("A1").Top + 4, 90, ws.Range("A1:D2").Height - 8)
    With resetBtn
        .Name = "btn_reset"
        .TextFrame2.TextRange.Text = T_Reset()
        .TextFrame2.TextRange.Font.Name = FONT_UI
        .TextFrame2.TextRange.Font.Size = 10
        .TextFrame2.TextRange.Font.Bold = msoTrue
        .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = C_SLATE
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
        .TextFrame2.VerticalAnchor = msoAnchorMiddle
        .Fill.ForeColor.RGB = C_PANEL
        .Line.ForeColor.RGB = C_BORDER
        .OnAction = "Reset_All_Reports"
    End With
End Sub

Sub Run_All_Reports()
    Dim currentStep As String
    On Error GoTo EH
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    Application.Calculation = xlCalculationManual
    currentStep = "Create_Monthly_Charts"
    Create_Monthly_Charts
    currentStep = "Create_Quarterly_Chart"
    Create_Quarterly_Chart
    currentStep = "Create_Forecast_Chart"
    Create_Forecast_Chart
    currentStep = "Create_Quality_Chart"
    Create_Quality_Chart
    currentStep = "Create_Cancel_Chart"
    Create_Cancel_Chart
    currentStep = "Create_Dashboard"
    Create_Dashboard
    Application.Calculation = xlCalculationAutomatic
    Application.DisplayAlerts = True
    Application.ScreenUpdating = True
    MsgBox K(Array(48372, 44256, 49436, 44032, 32, 49373, 49457, 46104, 50632, 49845, 45768, 45796)), vbInformation, "ESS ERP"
    Exit Sub
EH:
    Application.Calculation = xlCalculationAutomatic
    Application.DisplayAlerts = True
    Application.ScreenUpdating = True
    MsgBox K(Array(50724, 47448)) & ": " & Err.Number & " / " & Err.Description & vbCrLf & "Step: " & currentStep, vbCritical, "ESS ERP"
End Sub

Sub Reset_All_Reports()
    Dim ws As Worksheet
    DropSheet S_Dashboard()
    DropSheet S_Helper()
    Set ws = GetWS(S_Monthly()): If Not ws Is Nothing Then ClearCharts ws
    Set ws = GetWS(S_Quarterly()): If Not ws Is Nothing Then ClearCharts ws
    Set ws = GetWS(S_Forecast()): If Not ws Is Nothing Then ClearCharts ws
    Set ws = GetWS(S_Quality()): If Not ws Is Nothing Then ClearCharts ws
    Set ws = GetWS(S_Cancel()): If Not ws Is Nothing Then ClearCharts ws
    MsgBox K(Array(52488, 44592, 54868, 44032, 32, 50756, 47308, 46104, 50632, 49845, 45768, 45796)), vbInformation, "ESS ERP"
End Sub

Sub Create_Dashboard()
    Dim db As Worksheet, sm As Worksheet, mm As Worksheet, qt As Worksheet, fc As Worksheet, ql As Worksheet, cc As Worksheet
    Dim i As Long, lr As Long
    Dim stepName As String
    On Error GoTo EH
    Set sm = GetWS(S_Summary()): Set mm = GetWS(S_Monthly()): Set qt = GetWS(S_Quarterly()): Set fc = GetWS(S_Forecast()): Set ql = GetWS(S_Quality()): Set cc = GetWS(S_Cancel())
    If sm Is Nothing Then Exit Sub

    stepName = "DropSheet"
    DropSheet S_Dashboard()
    stepName = "Add Dashboard Sheet"
    Set db = ThisWorkbook.Worksheets.Add(Before:=ThisWorkbook.Worksheets(1))
    db.Name = S_Dashboard()
    db.Tab.Color = C_NAVY
    db.Cells.Interior.Color = RGB(248, 250, 252)
    ActiveWindow.DisplayGridlines = False
    ClearSheetShapes db

    For i = 1 To 24
        db.Columns(i).ColumnWidth = 6.8
    Next i
    db.Rows("1:82").RowHeight = 19
    db.Rows("1:3").RowHeight = 25
    db.Rows("4:4").RowHeight = 18
    db.Rows("6:9").RowHeight = 22
    db.Rows("11:28").RowHeight = 21
    db.Rows("30:47").RowHeight = 21
    db.Rows("49:66").RowHeight = 21
    db.Rows("68:79").RowHeight = 21

    stepName = "Header"
    With db.Range("A1:X3")
        .Merge
        .Value = T_Dash()
        .Font.Name = FONT_UI
        .Font.Size = 20
        .Font.Bold = True
        .Font.Color = C_PANEL
        .Interior.Color = C_NAVY
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
    End With
    With db.Range("A4:X4")
        .Merge
        .Value = K(Array(45824, 49884, 48372, 46300, 32, 54645, 49900, 32, 51648, 54364))
        .Font.Name = FONT_UI
        .Font.Size = 8.5
        .Font.Color = C_SLATE
        .Interior.Color = C_BG
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
    End With

    stepName = "Cards"
    DashboardFormulaCard db, "A6:D9", sm.Range("A6").Value, FxNum(FQ(sm.Name, "B6")), "KRW", C_NAVY
    DashboardFormulaCard db, "E6:H9", sm.Range("A8").Value, FxNum(FQ(sm.Name, "B8")), "KRW", C_GREEN
    DashboardFormulaCard db, "I6:L9", sm.Range("A9").Value, FxPct(FQ(sm.Name, "B9")), "", C_AMBER
    DashboardFormulaCard db, "M6:P9", sm.Range("A15").Value, FxPct(FQ(sm.Name, "B15")), "", C_GREEN
    DashboardFormulaCard db, "Q6:T9", sm.Range("A18").Value, FxNum(FQ(sm.Name, "B18")), "KRW", C_AMBER
    DashboardFormulaCard db, "U6:X9", sm.Range("A20").Value, FxPct(FQ(sm.Name, "B20")), "", C_NAVY

    stepName = "Monthly Panel"
    PanelFrame db, "A11:X28", mm.Range("A1").Value
    If Not mm Is Nothing Then
        CreateDashboardMonthlyLiveChart db, mm, "A12:R28"
        lr = LastDataRow(mm, "A")
        If lr >= 4 Then BuildMonthlySummary db, mm, sm, lr
    End If

    stepName = "Quarterly Panel"
    PanelFrame db, "A30:X47", qt.Range("A1").Value
    If Not qt Is Nothing Then
        CreateDashboardQuarterlyLiveChart db, qt, "A31:R47"
        lr = LastDataRow(qt, "A")
        If lr >= 4 Then BuildQuarterlySummary db, qt, sm, lr
    End If

    stepName = "Forecast Panel"
    PanelFrame db, "A49:X66", fc.Range("A1").Value
    If Not fc Is Nothing Then
        CreateDashboardForecastLiveChart db, fc, "A50:R66"
        lr = LastDataRow(fc, "A")
        If lr >= 3 Then BuildForecastSummary db, fc, lr
    End If

    stepName = "Quality Panel"
    If Not ql Is Nothing And Not cc Is Nothing Then
        PanelFrame db, "A68:X80", ql.Range("A1").Value & " / " & cc.Range("A1").Value
    ElseIf Not ql Is Nothing Then
        PanelFrame db, "A68:X80", ql.Range("A1").Value
    ElseIf Not cc Is Nothing Then
        PanelFrame db, "A68:X80", cc.Range("A1").Value
    End If
    If Not ql Is Nothing Then
        CreateDashboardQualityLiveChart db, ql, "A69:I80"
        BuildQualitySummary db, ql
    End If

    stepName = "Cancel Panel"
    If Not cc Is Nothing Then
        CreateDashboardCancelLiveChart db, cc, "J69:R80"
        BuildCancelSummary db, cc
    End If

    db.Activate
    ActiveWindow.Zoom = 85
    Exit Sub
EH:
    MsgBox K(Array(50724, 47448)) & ": " & Err.Number & " / " & Err.Description & vbCrLf & "Step: " & stepName, vbCritical, "ESS ERP"
End Sub

Private Sub ResetChartSeries(ByVal ch As Chart)
    On Error Resume Next
    Do While ch.SeriesCollection.Count > 0
        ch.SeriesCollection(1).Delete
    Loop
    On Error GoTo 0
End Sub

Private Sub MiniCombo(ByVal ch As Chart, ByVal ws As Worksheet, ByVal lr As Long, ByVal ttl As String)
    With ch
        ResetChartSeries ch
        .ChartType = xlColumnClustered
        .SeriesCollection.NewSeries
        .SeriesCollection(1).Values = ws.Range("B3:B" & lr)
        .SeriesCollection(1).XValues = ws.Range("A3:A" & lr)
        .SeriesCollection(1).Name = ws.Range("B2").Value
        .SeriesCollection.NewSeries
        .SeriesCollection(2).Values = ws.Range("E3:E" & lr)
        .SeriesCollection(2).XValues = ws.Range("A3:A" & lr)
        .SeriesCollection(2).Name = ws.Range("E2").Value
        .SeriesCollection(2).ChartType = xlLineMarkers
        .SeriesCollection(2).AxisGroup = xlSecondary
        .SeriesCollection(1).Format.Fill.ForeColor.RGB = C_NAVY
        .SeriesCollection(2).Format.Line.ForeColor.RGB = C_GREEN
        .SeriesCollection(2).MarkerForegroundColor = C_GREEN
        .SeriesCollection(2).MarkerBackgroundColor = C_PANEL
        ChartSkin ch, ttl, False
        .ChartGroups(1).GapWidth = 55
        On Error Resume Next
        .Axes(xlValue, xlSecondary).TickLabels.NumberFormat = "0%"
        .Axes(xlValue, xlSecondary).MaximumScale = 20
        .Axes(xlValue, xlSecondary).MinimumScale = -20
        On Error GoTo 0
    End With
End Sub

Private Sub ForecastMini(ByVal ch As Chart, ByVal ws As Worksheet, ByVal lr As Long)
    With ch
        ResetChartSeries ch
        .ChartType = xlLineMarkers
        .SeriesCollection.NewSeries
        .SeriesCollection(1).Values = ws.Range("B3:B" & lr)
        .SeriesCollection(1).XValues = ws.Range("A3:A" & lr)
        .SeriesCollection(1).Name = ws.Range("B2").Value
        .SeriesCollection(1).Format.Line.ForeColor.RGB = C_NAVY
        .SeriesCollection(1).Format.Line.Weight = 2
        .SeriesCollection(1).MarkerForegroundColor = C_NAVY
        .SeriesCollection(1).MarkerBackgroundColor = C_PANEL
        ChartSkin ch, T_Forecast(), False
    End With
End Sub

Private Sub QualityPie(ByVal ch As Chart, ByVal ws As Worksheet)
    With ch
        ResetChartSeries ch
        .ChartType = xlDoughnut
        .SetSourceData ws.Range("A3:B4")
        .SeriesCollection(1).Points(1).Format.Fill.ForeColor.RGB = C_STEEL
        .SeriesCollection(1).Points(2).Format.Fill.ForeColor.RGB = C_GREEN
        On Error Resume Next
        .DoughnutGroups(1).DoughnutHoleSize = 70
        .SeriesCollection(1).Points(1).Format.Line.Visible = msoTrue
        .SeriesCollection(1).Points(1).Format.Line.ForeColor.RGB = C_NAVY_DARK
        .SeriesCollection(1).Points(1).Format.Line.Weight = 1.2
        .SeriesCollection(1).Points(2).Format.Line.Visible = msoTrue
        .SeriesCollection(1).Points(2).Format.Line.ForeColor.RGB = RGB(56, 100, 86)
        .SeriesCollection(1).Points(2).Format.Line.Weight = 1.2
        .SeriesCollection(1).Points(2).Explosion = 10
        .SeriesCollection(1).ApplyDataLabels
        .SeriesCollection(1).DataLabels.ShowCategoryName = True
        .SeriesCollection(1).DataLabels.ShowPercentage = True
        .SeriesCollection(1).DataLabels.ShowValue = False
        .SeriesCollection(1).HasLeaderLines = True
        .SeriesCollection(1).DataLabels.Font.Name = FONT_UI
        .SeriesCollection(1).DataLabels.Font.Size = 9
        .SeriesCollection(1).DataLabels.Font.Bold = True
        .SeriesCollection(1).Points(1).DataLabel.Font.Color = C_NAVY
        .SeriesCollection(1).Points(2).DataLabel.Font.Color = C_GREEN
        On Error GoTo 0
        ChartSkin ch, T_Quality(), False
        ForceDonutLabelsOutside ch
    End With
End Sub

Private Sub CancelPareto(ByVal ch As Chart, ByVal ws As Worksheet, ByVal hp As Worksheet)
    hp.Range("F1:H3").ClearContents
    hp.Range("F1:H1").Value = Array(K(Array(44396, 48516)), K(Array(44148, 49688)), K(Array(48708, 51473, 47456)))
    hp.Range("F2").Value = K(Array(51221, 49345))
    hp.Range("G2").Value = ws.Range("B4").Value
    hp.Range("F3").Value = K(Array(52712, 49548))
    hp.Range("G3").Value = ws.Range("B5").Value
    hp.Range("H2").Formula = "=G2/SUM($G$2:$G$3)"
    hp.Range("H3").Formula = "=G3/SUM($G$2:$G$3)"
    With ch
        ResetChartSeries ch
        .ChartType = xlDoughnut
        .SetSourceData hp.Range("F2:G3")
        .SeriesCollection(1).Points(1).Format.Fill.ForeColor.RGB = C_STEEL
        .SeriesCollection(1).Points(2).Format.Fill.ForeColor.RGB = C_AMBER
        On Error Resume Next
        .DoughnutGroups(1).DoughnutHoleSize = 70
        .SeriesCollection(1).Points(1).Format.Line.Visible = msoTrue
        .SeriesCollection(1).Points(1).Format.Line.ForeColor.RGB = C_NAVY_DARK
        .SeriesCollection(1).Points(1).Format.Line.Weight = 1.2
        .SeriesCollection(1).Points(2).Format.Line.Visible = msoTrue
        .SeriesCollection(1).Points(2).Format.Line.ForeColor.RGB = RGB(138, 92, 56)
        .SeriesCollection(1).Points(2).Format.Line.Weight = 1.2
        .SeriesCollection(1).Points(2).Explosion = 10
        .SeriesCollection(1).ApplyDataLabels
        .SeriesCollection(1).DataLabels.ShowCategoryName = True
        .SeriesCollection(1).DataLabels.ShowPercentage = True
        .SeriesCollection(1).DataLabels.ShowValue = False
        .SeriesCollection(1).HasLeaderLines = True
        .SeriesCollection(1).DataLabels.Font.Name = FONT_UI
        .SeriesCollection(1).DataLabels.Font.Size = 9
        .SeriesCollection(1).DataLabels.Font.Bold = True
        .SeriesCollection(1).Points(1).DataLabel.Font.Color = C_NAVY
        .SeriesCollection(1).Points(2).DataLabel.Font.Color = C_AMBER
        On Error GoTo 0
        ChartSkin ch, T_Cancel(), False
        ForceDonutLabelsOutside ch
    End With
End Sub

Sub Create_Monthly_Charts()
    Dim ws As Worksheet, lr As Long, co As ChartObject
    Dim xVals() As Variant, revVals() As Double, costVals() As Double, marginVals() As Double
    Dim i As Long, idx As Long
    Set ws = GetWS(S_Monthly())
    If ws Is Nothing Then Exit Sub
    ClearCharts ws
    lr = LastDataRow(ws, "A")
    If lr < 3 Then Exit Sub
    ReDim xVals(1 To lr - 2)
    ReDim revVals(1 To lr - 2)
    ReDim costVals(1 To lr - 2)
    ReDim marginVals(1 To lr - 2)
    idx = 1
    For i = 3 To lr
        xVals(idx) = ShortMonthLabel(ws.Range("A" & i).Value)
        revVals(idx) = ToEok(ws.Range("B" & i).Value)
        costVals(idx) = ToEok(ws.Range("C" & i).Value)
        marginVals(idx) = ws.Range("E" & i).Value
        idx = idx + 1
    Next i
    Set co = ws.ChartObjects.Add(ws.Columns("I").Left, ws.Rows(2).Top, 520, 280)
    With co.Chart
        .ChartType = xlColumnClustered
        .SeriesCollection.NewSeries
        .SeriesCollection(1).Values = revVals
        .SeriesCollection(1).XValues = xVals
        .SeriesCollection(1).Name = ws.Range("B2").Value
        .SeriesCollection.NewSeries
        .SeriesCollection(2).Values = costVals
        .SeriesCollection(2).XValues = xVals
        .SeriesCollection(2).Name = ws.Range("C2").Value
        .SeriesCollection.NewSeries
        .SeriesCollection(3).Values = marginVals
        .SeriesCollection(3).XValues = xVals
        .SeriesCollection(3).Name = ws.Range("E2").Value
        .SeriesCollection(3).ChartType = xlLineMarkers
        .SeriesCollection(3).AxisGroup = xlSecondary
        .SeriesCollection(1).Format.Fill.ForeColor.RGB = C_NAVY
        .SeriesCollection(2).Format.Fill.ForeColor.RGB = C_STEEL
        .SeriesCollection(3).Format.Line.ForeColor.RGB = C_GREEN
        .SeriesCollection(3).MarkerForegroundColor = C_GREEN
        .SeriesCollection(3).MarkerBackgroundColor = C_PANEL
        .HasLegend = True
        ChartSkin co.Chart, T_Monthly()
        ApplyKrwAxis co.Chart, 3, 45
        .ChartGroups(1).GapWidth = 55
        On Error Resume Next
        .Axes(xlValue, xlSecondary).TickLabels.NumberFormat = "0%"
        .Axes(xlValue, xlSecondary).MaximumScale = 20
        .Axes(xlValue, xlSecondary).MinimumScale = -20
        On Error GoTo 0
    End With
End Sub

Sub Create_Quarterly_Chart()
    Dim ws As Worksheet, lr As Long, co As ChartObject
    Dim xVals() As Variant, revVals() As Double, profitVals() As Double, marginVals() As Double
    Dim forecastFlags() As Boolean
    Dim i As Long, idx As Long, p As Long
    Set ws = GetWS(S_Quarterly())
    If ws Is Nothing Then Exit Sub
    ClearCharts ws
    lr = LastDataRow(ws, "A")
    If lr < 3 Then Exit Sub
    ReDim xVals(1 To lr - 2)
    ReDim revVals(1 To lr - 2)
    ReDim profitVals(1 To lr - 2)
    ReDim marginVals(1 To lr - 2)
    ReDim forecastFlags(1 To lr - 2)
    idx = 1
    For i = 3 To lr
        xVals(idx) = QuarterChartLabel(ws.Range("A" & i).Value)
        revVals(idx) = ToEok(ws.Range("B" & i).Value)
        profitVals(idx) = ToEok(ws.Range("D" & i).Value)
        marginVals(idx) = ws.Range("E" & i).Value
        forecastFlags(idx) = (InStr(CStr(ws.Range("A" & i).Value), K(Array(50696, 52769))) > 0)
        idx = idx + 1
    Next i
    Set co = ws.ChartObjects.Add(ws.Columns("H").Left, ws.Rows(2).Top, 500, 280)
    With co.Chart
        .ChartType = xlColumnClustered
        .SeriesCollection.NewSeries
        .SeriesCollection(1).Values = revVals
        .SeriesCollection(1).XValues = xVals
        .SeriesCollection(1).Name = ws.Range("B2").Value
        .SeriesCollection.NewSeries
        .SeriesCollection(2).Values = profitVals
        .SeriesCollection(2).XValues = xVals
        .SeriesCollection(2).Name = ws.Range("D2").Value
        .SeriesCollection.NewSeries
        .SeriesCollection(3).Values = marginVals
        .SeriesCollection(3).XValues = xVals
        .SeriesCollection(3).Name = ws.Range("E2").Value
        .SeriesCollection(3).ChartType = xlLineMarkers
        .SeriesCollection(3).AxisGroup = xlSecondary
        .SeriesCollection(1).Format.Fill.ForeColor.RGB = C_NAVY
        .SeriesCollection(2).Format.Fill.ForeColor.RGB = C_STEEL
        .SeriesCollection(3).Format.Line.ForeColor.RGB = C_GREEN
        .SeriesCollection(3).MarkerForegroundColor = C_GREEN
        .SeriesCollection(3).MarkerBackgroundColor = C_PANEL
        For p = 1 To (lr - 2)
            If forecastFlags(p) Then
                .SeriesCollection(1).Points(p).Format.Fill.ForeColor.RGB = C_GREEN
                .SeriesCollection(2).Points(p).Format.Fill.ForeColor.RGB = C_PANEL_TINT
            End If
        Next p
        ChartSkin co.Chart, T_Quarterly()
        ApplyKrwAxis co.Chart, 1, 35
        .ChartGroups(1).GapWidth = 65
        On Error Resume Next
        .Axes(xlValue, xlSecondary).TickLabels.NumberFormat = "0%"
        .Axes(xlValue, xlSecondary).MaximumScale = 20
        .Axes(xlValue, xlSecondary).MinimumScale = -10
        On Error GoTo 0
    End With
End Sub

Sub Create_Forecast_Chart()
    Dim ws As Worksheet, lr As Long, co As ChartObject
    Dim xVals() As Variant, revVals() As Double, profitVals() As Double
    Dim i As Long, idx As Long, lastIdx As Long
    Set ws = GetWS(S_Forecast())
    If ws Is Nothing Then Exit Sub
    ClearCharts ws
    lr = LastDataRow(ws, "A")
    If lr < 3 Then Exit Sub
    ReDim xVals(1 To lr - 2)
    ReDim revVals(1 To lr - 2)
    ReDim profitVals(1 To lr - 2)
    idx = 1
    For i = 3 To lr
        xVals(idx) = ShortMonthLabel(ws.Range("A" & i).Value)
        revVals(idx) = ToEok(ws.Range("B" & i).Value)
        profitVals(idx) = ToEok(ws.Range("D" & i).Value)
        idx = idx + 1
    Next i
    lastIdx = lr - 2
    Set co = ws.ChartObjects.Add(ws.Columns("G").Left, ws.Rows(2).Top, 500, 280)
    With co.Chart
        .ChartType = xlLineMarkers
        .SeriesCollection.NewSeries
        .SeriesCollection(1).Values = revVals
        .SeriesCollection(1).XValues = xVals
        .SeriesCollection(1).Name = ws.Range("B2").Value
        .SeriesCollection.NewSeries
        .SeriesCollection(2).Values = profitVals
        .SeriesCollection(2).XValues = xVals
        .SeriesCollection(2).Name = ws.Range("D2").Value
        .SeriesCollection(2).ChartType = xlLineMarkers
        .SeriesCollection(1).Format.Line.ForeColor.RGB = C_NAVY
        .SeriesCollection(1).Format.Line.Weight = 2.25
        .SeriesCollection(1).MarkerForegroundColor = C_NAVY
        .SeriesCollection(1).MarkerBackgroundColor = C_PANEL
        .SeriesCollection(1).MarkerSize = 6
        .SeriesCollection(1).Smooth = True
        .SeriesCollection(2).Format.Line.ForeColor.RGB = C_GREEN
        .SeriesCollection(2).Format.Line.Weight = 1.75
        .SeriesCollection(2).MarkerForegroundColor = C_GREEN
        .SeriesCollection(2).MarkerBackgroundColor = C_PANEL
        .SeriesCollection(2).MarkerSize = 6
        .SeriesCollection(2).Smooth = True
        On Error Resume Next
        .SeriesCollection(1).Trendlines.Add
        .SeriesCollection(1).Trendlines(1).Format.Line.ForeColor.RGB = C_STEEL
        .SeriesCollection(1).Trendlines(1).Format.Line.Weight = 1
        .SeriesCollection(1).Points(lastIdx).HasDataLabel = True
        .SeriesCollection(1).Points(lastIdx).DataLabel.Text = Format(revVals(lastIdx), "0.0") & K(Array(50613, 50896))
        .SeriesCollection(2).Points(lastIdx).HasDataLabel = True
        .SeriesCollection(2).Points(lastIdx).DataLabel.Text = Format(profitVals(lastIdx), "0.0") & K(Array(50613, 50896))
        .SeriesCollection(1).Points(lastIdx).DataLabel.Font.Name = FONT_UI
        .SeriesCollection(1).Points(lastIdx).DataLabel.Font.Size = 8
        .SeriesCollection(2).Points(lastIdx).DataLabel.Font.Name = FONT_UI
        .SeriesCollection(2).Points(lastIdx).DataLabel.Font.Size = 8
        On Error GoTo 0
        ChartSkin co.Chart, T_Forecast()
        .HasLegend = True
        ApplyKrwAxis co.Chart, 2, 0
    End With
End Sub

Sub Create_Quality_Chart()
    Dim ws As Worksheet, co As ChartObject
    Set ws = GetWS(S_Quality())
    If ws Is Nothing Then Exit Sub
    ClearCharts ws
    Set co = ws.ChartObjects.Add(ws.Columns("E").Left, ws.Rows(2).Top, 460, 280)
    QualityPie co.Chart, ws
End Sub

Sub Create_Cancel_Chart()
    Dim ws As Worksheet, hp As Worksheet, co As ChartObject
    Set ws = GetWS(S_Cancel())
    If ws Is Nothing Then Exit Sub
    ClearCharts ws
    Set hp = GetWS(S_Helper())
    If hp Is Nothing Then
        Set hp = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        hp.Name = S_Helper()
        hp.Visible = xlSheetVeryHidden
    End If
    Set co = ws.ChartObjects.Add(ws.Columns("E").Left, ws.Rows(2).Top, 460, 280)
    CancelPareto co.Chart, ws, hp
End Sub

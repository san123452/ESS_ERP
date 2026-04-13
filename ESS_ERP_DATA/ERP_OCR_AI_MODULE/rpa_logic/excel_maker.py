import pandas as pd
import io
from openpyxl.styles import Font, Alignment, PatternFill, Border, Side
from openpyxl.chart import LineChart, BarChart, Reference
from openpyxl.utils import get_column_letter

# ── 공통 스타일 상수 ──────────────────────────────────────────
HEADER_FILL  = PatternFill(start_color="1F4E79", end_color="1F4E79", fill_type="solid")
SUBHDR_FILL  = PatternFill(start_color="2E75B6", end_color="2E75B6", fill_type="solid")
ALT_FILL     = PatternFill(start_color="EBF3FB", end_color="EBF3FB", fill_type="solid")
TOTAL_FILL   = PatternFill(start_color="D6E4F0", end_color="D6E4F0", fill_type="solid")
HEADER_FONT  = Font(name="Arial", color="FFFFFF", bold=True, size=10)
BODY_FONT    = Font(name="Arial", size=10)
BOLD_FONT    = Font(name="Arial", bold=True, size=10)
TITLE_FONT   = Font(name="Arial", bold=True, size=14, color="1F4E79")
C_CENTER     = Alignment(horizontal="center", vertical="center")
C_RIGHT      = Alignment(horizontal="right",  vertical="center")
C_LEFT       = Alignment(horizontal="left",   vertical="center")
THIN         = Side(style="thin", color="B0C4DE")
BORDER       = Border(left=THIN, right=THIN, top=THIN, bottom=THIN)
NUM_FMT      = '#,##0'
PCT_FMT      = '0.00"%"'

def _style_header_row(ws, row_num, ncols):
    for c in range(1, ncols + 1):
        cell = ws.cell(row=row_num, column=c)
        cell.fill   = HEADER_FILL
        cell.font   = HEADER_FONT
        cell.alignment = C_CENTER
        cell.border = BORDER

def _style_body_row(ws, row_num, ncols, alt=False):
    for c in range(1, ncols + 1):
        cell = ws.cell(row=row_num, column=c)
        if alt:
            cell.fill = ALT_FILL
        cell.font   = BODY_FONT
        cell.border = BORDER
        if isinstance(cell.value, (int, float)):
            cell.number_format = NUM_FMT
            cell.alignment     = C_RIGHT
        else:
            cell.alignment = C_LEFT

def _auto_col_width(ws):
    for col in ws.columns:
        max_len = 0
        col_letter = get_column_letter(col[0].column)
        for cell in col:
            if cell.value:
                max_len = max(max_len, len(str(cell.value)))
        ws.column_dimensions[col_letter].width = min(max(max_len * 1.6, 13), 52)


def generate_excel_report(analysis_data):
    output = io.BytesIO()
    raw = analysis_data.get('data', analysis_data)

    with pd.ExcelWriter(output, engine='openpyxl') as writer:

        # ══════════════════════════════════════════════
        # [Sheet 1] 경영 요약 (Executive Summary)
        # ══════════════════════════════════════════════
        ws = writer.book.create_sheet("Executive_Summary")
        writer.sheets["Executive_Summary"] = ws

        f  = raw.get('financial_summary', {})
        p  = raw.get('prediction', {})
        qm = raw.get('quality_metrics', {})

        ws['A1'] = "ESS 사업부 경영 성과 요약"
        ws['A1'].font      = TITLE_FONT
        ws['A1'].alignment = C_LEFT
        ws.row_dimensions[1].height = 28
        ws.merge_cells('A1:D1')

        headers = ["지표", "실적값", "단위", "비고"]
        rows = [
            ("총 매출액",        f.get('total_revenue', 0),       "원",  "VAT 포함"),
            ("총 원가",          f.get('total_cost', 0),           "원",  "BOM 기준 원자재비"),
            ("매출이익",         f.get('gross_profit', 0),         "원",  "매출액 - 원가"),
            ("순이익률",         f.get('net_margin_rate', 0),      "%",   ""),
            ("총 수주건수",      f.get('total_orders', 0),         "건",  ""),
            ("평균 수주금액",    f.get('avg_order_value', 0),      "원",  ""),
            ("─── 생산 품질 ───", "", "", ""),
            ("양품 수량",        qm.get('total_good', 0),          "EA",  ""),
            ("불량 수량",        qm.get('total_bad',  0),          "EA",  ""),
            ("수율",             qm.get('yield_rate', 0),          "%",   ""),
            ("불량 기회비용",    raw.get('loss_cost', 0),          "원",  "불량수 × 단위원가"),
            ("─── AI 예측 ───",  "", "", ""),
            ("60일 예상매출",    p.get('predicted_revenue', 0),    "원",  p.get('message', '')),
            ("60일 예상이익",    p.get('predicted_profit',  0),    "원",  ""),
            ("예상 이익률",      p.get('margin_rate', 0),          "%",   ""),
        ]

        for ci, h in enumerate(headers, 1):
            cell = ws.cell(row=2, column=ci, value=h)
            cell.fill      = HEADER_FILL
            cell.font      = HEADER_FONT
            cell.alignment = C_CENTER
            cell.border    = BORDER

        for ri, row in enumerate(rows, 3):
            for ci, val in enumerate(row, 1):
                cell = ws.cell(row=ri, column=ci, value=val)
                cell.border = BORDER
                cell.font   = BODY_FONT
                if ci == 1:
                    cell.alignment = C_LEFT
                    if str(val).startswith('───'):
                        cell.fill = SUBHDR_FILL
                        cell.font = Font(name="Arial", color="FFFFFF", bold=True, size=10)
                elif ci == 2 and isinstance(val, (int, float)) and val != 0:
                    unit = row[2]
                    cell.number_format = PCT_FMT if unit == "%" else NUM_FMT
                    cell.alignment     = C_RIGHT
                else:
                    cell.alignment = C_LEFT
            if ri % 2 == 0:
                for ci in range(1, 5):
                    c = ws.cell(row=ri, column=ci)
                    if not c.fill or c.fill.start_color.rgb in ('00000000', 'FFFFFFFF'):
                        c.fill = ALT_FILL

        ws.column_dimensions['A'].width = 22
        ws.column_dimensions['B'].width = 20
        ws.column_dimensions['C'].width = 8
        ws.column_dimensions['D'].width = 38

        # ══════════════════════════════════════════════
        # [Sheet 2] 월별 손익 (Monthly P&L)
        # ══════════════════════════════════════════════
        monthly_data = raw.get('monthly_performance', [])
        if monthly_data:
            ws2 = writer.book.create_sheet("Monthly_PL")
            writer.sheets["Monthly_PL"] = ws2

            ws2['A1'] = "월별 손익 현황"
            ws2['A1'].font = TITLE_FONT
            ws2.merge_cells('A1:G1')
            ws2.row_dimensions[1].height = 24

            cols = ["결산월", "매출액", "매출원가", "매출이익", "이익률(%)", "수주건수", "평균단가"]
            for ci, h in enumerate(cols, 1):
                ws2.cell(row=2, column=ci, value=h)
            _style_header_row(ws2, 2, len(cols))

            for ri, m in enumerate(monthly_data, 3):
                rev   = m.get('revenue', 0)
                cost  = m.get('cost', 0)
                prof  = m.get('profit', 0)
                cnt   = m.get('order_count', 0)
                avg   = int(rev / cnt) if cnt > 0 else 0
                row_vals = [m['month'], rev, cost, prof, m.get('margin_rate', 0), cnt, avg]
                for ci, val in enumerate(row_vals, 1):
                    cell = ws2.cell(row=ri, column=ci, value=val)
                    cell.border = BORDER
                    cell.font   = BODY_FONT
                    if ci == 1:
                        cell.alignment = C_CENTER
                    elif ci == 5:  # 이익률
                        cell.number_format = PCT_FMT
                        cell.alignment     = C_RIGHT
                    elif isinstance(val, (int, float)):
                        cell.number_format = NUM_FMT
                        cell.alignment     = C_RIGHT
                if ri % 2 == 0:
                    for ci in range(1, len(cols)+1):
                        ws2.cell(row=ri, column=ci).fill = ALT_FILL

            # 합계 행
            last_r = 2 + len(monthly_data)
            total_row = ["합  계",
                         f"=SUM(B3:B{last_r})", f"=SUM(C3:C{last_r})", f"=SUM(D3:D{last_r})",
                         f"=IFERROR(D{last_r+1}/B{last_r+1}*100,0)",
                         f"=SUM(F3:F{last_r})", ""]
            for ci, val in enumerate(total_row, 1):
                cell = ws2.cell(row=last_r+1, column=ci, value=val)
                cell.fill   = TOTAL_FILL
                cell.font   = BOLD_FONT
                cell.border = BORDER
                if ci == 5:
                    cell.number_format = PCT_FMT
                    cell.alignment     = C_RIGHT
                elif ci > 1:
                    cell.number_format = NUM_FMT
                    cell.alignment     = C_RIGHT

            # 월별 매출/이익 라인차트
            chart = LineChart()
            chart.title  = "월별 매출 및 이익 추이"
            chart.y_axis.title = "금액 (원)"
            chart.x_axis.title = "결산월"
            chart.width  = 22
            chart.height = 14
            rev_ref  = Reference(ws2, min_col=2, min_row=2, max_row=last_r)
            prof_ref = Reference(ws2, min_col=4, min_row=2, max_row=last_r)
            cats_ref = Reference(ws2, min_col=1, min_row=3, max_row=last_r)
            chart.add_data(rev_ref,  titles_from_data=True)
            chart.add_data(prof_ref, titles_from_data=True)
            chart.set_categories(cats_ref)
            chart.series[0].graphicalProperties.line.solidFill  = "1F4E79"
            chart.series[0].graphicalProperties.line.width      = 20000
            chart.series[1].graphicalProperties.line.solidFill  = "70AD47"
            chart.series[1].graphicalProperties.line.width      = 20000
            ws2.add_chart(chart, "I2")
            _auto_col_width(ws2)

        # ══════════════════════════════════════════════
        # [Sheet 3] 분기별 실적 (Quarterly Performance)
        # ══════════════════════════════════════════════
        quarterly_data = raw.get('quarterly_chart', [])
        if quarterly_data:
            ws3 = writer.book.create_sheet("Quarterly_Performance")
            writer.sheets["Quarterly_Performance"] = ws3

            ws3['A1'] = "분기별 경영 실적"
            ws3['A1'].font = TITLE_FONT
            ws3.merge_cells('A1:F1')
            ws3.row_dimensions[1].height = 24

            cols = ["분기", "매출액", "매출원가", "매출이익", "이익률(%)", "수주건수"]
            for ci, h in enumerate(cols, 1):
                ws3.cell(row=2, column=ci, value=h)
            _style_header_row(ws3, 2, len(cols))

            for ri, q in enumerate(quarterly_data, 3):
                row_vals = [
                    q.get('label', q.get('quarter', '')),
                    q.get('revenue', 0), q.get('cost', 0), q.get('profit', 0),
                    q.get('margin_rate', 0), q.get('order_count', 0)
                ]
                for ci, val in enumerate(row_vals, 1):
                    cell = ws3.cell(row=ri, column=ci, value=val)
                    cell.border = BORDER
                    cell.font   = BODY_FONT
                    if ci == 1:
                        cell.alignment = C_CENTER
                    elif ci == 5:
                        cell.number_format = PCT_FMT
                        cell.alignment     = C_RIGHT
                    elif isinstance(val, (int, float)):
                        cell.number_format = NUM_FMT
                        cell.alignment     = C_RIGHT
                if ri % 2 == 0:
                    for ci in range(1, len(cols)+1):
                        ws3.cell(row=ri, column=ci).fill = ALT_FILL

            last_r = 2 + len(quarterly_data)
            total_row = ["합  계",
                         f"=SUM(B3:B{last_r})", f"=SUM(C3:C{last_r})", f"=SUM(D3:D{last_r})",
                         f"=IFERROR(D{last_r+1}/B{last_r+1}*100,0)",
                         f"=SUM(F3:F{last_r})"]
            for ci, val in enumerate(total_row, 1):
                cell = ws3.cell(row=last_r+1, column=ci, value=val)
                cell.fill   = TOTAL_FILL
                cell.font   = BOLD_FONT
                cell.border = BORDER
                if ci == 5:
                    cell.number_format = PCT_FMT
                    cell.alignment     = C_RIGHT
                elif ci > 1:
                    cell.number_format = NUM_FMT
                    cell.alignment     = C_RIGHT

            # 분기별 묶음 막대 차트 (매출/이익)
            chart_q = BarChart()
            chart_q.type    = "col"
            chart_q.title   = "분기별 매출 및 이익"
            chart_q.y_axis.title = "금액 (원)"
            chart_q.width   = 20
            chart_q.height  = 14
            rev_ref  = Reference(ws3, min_col=2, min_row=2, max_row=last_r)
            prof_ref = Reference(ws3, min_col=4, min_row=2, max_row=last_r)
            cats_ref = Reference(ws3, min_col=1, min_row=3, max_row=last_r)
            chart_q.add_data(rev_ref,  titles_from_data=True)
            chart_q.add_data(prof_ref, titles_from_data=True)
            chart_q.set_categories(cats_ref)
            chart_q.series[0].graphicalProperties.solidFill = "1F4E79"
            chart_q.series[1].graphicalProperties.solidFill = "70AD47"
            ws3.add_chart(chart_q, "H2")
            _auto_col_width(ws3)

        # ══════════════════════════════════════════════
        # [Sheet 4] AI 장기 예측 (Financial Forecast)
        # ══════════════════════════════════════════════
        if 'long_term_forecast' in raw:
            ws4 = writer.book.create_sheet("Financial_Forecast")
            writer.sheets["Financial_Forecast"] = ws4

            ws4['A1'] = "AI 기반 12개월 매출 예측 (Holt-Winters)"
            ws4['A1'].font = TITLE_FONT
            ws4.merge_cells('A1:E1')
            ws4.row_dimensions[1].height = 24

            cols = ["예측월", "예상매출액", "예상원가", "예상이익", "예상이익률(%)"]
            for ci, h in enumerate(cols, 1):
                ws4.cell(row=2, column=ci, value=h)
            _style_header_row(ws4, 2, len(cols))

            for ri, fc in enumerate(raw['long_term_forecast'], 3):
                rev  = fc.get('predicted_revenue', 0)
                cost = fc.get('predicted_cost', 0)
                prof = fc.get('predicted_profit', 0)
                margin = fc.get('margin_rate', round((prof/rev)*100, 2) if rev > 0 else 0)
                row_vals = [fc['month'], rev, cost, prof, margin]
                for ci, val in enumerate(row_vals, 1):
                    cell = ws4.cell(row=ri, column=ci, value=val)
                    cell.border = BORDER
                    cell.font   = BODY_FONT
                    if ci == 1:
                        cell.alignment = C_CENTER
                    elif ci == 5:
                        cell.number_format = PCT_FMT
                        cell.alignment     = C_RIGHT
                    elif isinstance(val, (int, float)):
                        cell.number_format = NUM_FMT
                        cell.alignment     = C_RIGHT
                if ri % 2 == 0:
                    for ci in range(1, len(cols)+1):
                        ws4.cell(row=ri, column=ci).fill = ALT_FILL

            last_r = 2 + len(raw['long_term_forecast'])
            total_row = ["합  계",
                         f"=SUM(B3:B{last_r})", f"=SUM(C3:C{last_r})", f"=SUM(D3:D{last_r})",
                         f"=IFERROR(D{last_r+1}/B{last_r+1}*100,0)"]
            for ci, val in enumerate(total_row, 1):
                cell = ws4.cell(row=last_r+1, column=ci, value=val)
                cell.fill   = TOTAL_FILL
                cell.font   = BOLD_FONT
                cell.border = BORDER
                if ci == 5:
                    cell.number_format = PCT_FMT
                    cell.alignment     = C_RIGHT
                elif ci > 1:
                    cell.number_format = NUM_FMT
                    cell.alignment     = C_RIGHT

            # 예측 매출 라인차트
            chart_f = LineChart()
            chart_f.title  = "12개월 매출 예측 추이"
            chart_f.y_axis.title = "금액 (원)"
            chart_f.width  = 22
            chart_f.height = 14
            rev_ref  = Reference(ws4, min_col=2, min_row=2, max_row=last_r)
            prof_ref = Reference(ws4, min_col=4, min_row=2, max_row=last_r)
            cats_ref = Reference(ws4, min_col=1, min_row=3, max_row=last_r)
            chart_f.add_data(rev_ref,  titles_from_data=True)
            chart_f.add_data(prof_ref, titles_from_data=True)
            chart_f.set_categories(cats_ref)
            chart_f.series[0].graphicalProperties.line.solidFill = "2E75B6"
            chart_f.series[0].graphicalProperties.line.width      = 20000
            chart_f.series[1].graphicalProperties.line.solidFill  = "70AD47"
            chart_f.series[1].graphicalProperties.line.width      = 20000
            ws4.add_chart(chart_f, "G2")
            _auto_col_width(ws4)

        # ══════════════════════════════════════════════
        # [Sheet 5] 품질 분석 (Quality Analysis)
        # ══════════════════════════════════════════════
        if 'quality_metrics' in raw:
            ws5 = writer.book.create_sheet("Quality_Analysis")
            writer.sheets["Quality_Analysis"] = ws5

            ws5['A1'] = "생산 품질 분석"
            ws5['A1'].font = TITLE_FONT
            ws5.merge_cells('A1:C1')
            ws5.row_dimensions[1].height = 24

            qm = raw['quality_metrics']
            q_rows = [
                ("구분", "수량", "비율(%)"),
                ("양품",    qm.get('total_good', 0), f"=B3/(B3+B4)*100"),
                ("불량",    qm.get('total_bad',  0), f"=B4/(B3+B4)*100"),
                ("합계",    f"=B3+B4",               "100.00"),
                ("수율",    "",                       qm.get('yield_rate', 0)),
                ("불량기회비용(원)", raw.get('loss_cost', 0), ""),
            ]
            for ri, row in enumerate(q_rows, 2):
                for ci, val in enumerate(row, 1):
                    cell = ws5.cell(row=ri, column=ci, value=val)
                    cell.border = BORDER
                    if ri == 2:
                        cell.fill      = HEADER_FILL
                        cell.font      = HEADER_FONT
                        cell.alignment = C_CENTER
                    else:
                        cell.font = BODY_FONT
                        if ci == 3 and ri > 2:
                            cell.number_format = PCT_FMT
                            cell.alignment     = C_RIGHT
                        elif isinstance(val, (int, float)):
                            cell.number_format = NUM_FMT
                            cell.alignment     = C_RIGHT
                        else:
                            cell.alignment = C_LEFT

            ws5.column_dimensions['A'].width = 22
            ws5.column_dimensions['B'].width = 18
            ws5.column_dimensions['C'].width = 14

            # ══════════════════════════════════════════════
        # [Sheet 6] 취소율 분석 (Cancel Analysis)
        # ══════════════════════════════════════════════
        if 'cancel_analysis' in raw:
            ws6 = writer.book.create_sheet("Cancel_Analysis")
            writer.sheets["Cancel_Analysis"] = ws6

            ws6['A1'] = "수주 취소율 분석"
            ws6['A1'].font = TITLE_FONT
            ws6.merge_cells('A1:C1')
            ws6.row_dimensions[1].height = 24

            ca = raw['cancel_analysis']
            c_rows = [
                ("구분",         "건수",                    "비율(%)"),
                ("전체 수주",    ca.get('total_orders',  0), "100.00"),
                ("정상 수주",    ca.get('done_orders',   0), f"=B3/B2*100"),
                ("취소 수주",    ca.get('cancel_orders', 0), f"=B4/B2*100"),
                ("취소 매출손실(원)", ca.get('cancel_amount', 0), ""),
                ("취소율",       "",                        ca.get('cancel_rate', 0)),
            ]
            for ri, row in enumerate(c_rows, 2):
                for ci, val in enumerate(row, 1):
                    cell = ws6.cell(row=ri, column=ci, value=val)
                    cell.border = BORDER
                    if ri == 2:
                        cell.fill      = HEADER_FILL
                        cell.font      = HEADER_FONT
                        cell.alignment = C_CENTER
                    else:
                        cell.font = BODY_FONT
                        if ci == 3 and isinstance(val, (int, float)):
                            cell.number_format = PCT_FMT
                            cell.alignment     = C_RIGHT
                        elif ci == 3 and isinstance(val, str) and val.startswith('='):
                            cell.number_format = PCT_FMT
                            cell.alignment     = C_RIGHT
                        elif isinstance(val, (int, float)) and val != 0:
                            cell.number_format = NUM_FMT
                            cell.alignment     = C_RIGHT
                        else:
                            cell.alignment = C_LEFT
                if ri % 2 == 0:
                    for ci in range(1, 4):
                        c = ws6.cell(row=ri, column=ci)
                        if not c.fill or c.fill.fgColor.rgb in ('00000000', 'FFFFFFFF'):
                            c.fill = ALT_FILL

            # 취소/정상 수주 도넛 차트
            from openpyxl.chart import PieChart
            chart_c = PieChart()
            chart_c.title  = "수주 현황 (정상 vs 취소)"
            chart_c.width  = 16
            chart_c.height = 12
            data_ref = Reference(ws6, min_col=2, min_row=2, max_row=4)
            cats_ref = Reference(ws6, min_col=1, min_row=3, max_row=4)
            chart_c.add_data(data_ref, titles_from_data=True)
            chart_c.set_categories(cats_ref)
            chart_c.series[0].graphicalProperties.solidFill = "1F4E79"
            ws6.add_chart(chart_c, "E2")

            ws6.column_dimensions['A'].width = 22
            ws6.column_dimensions['B'].width = 18
            ws6.column_dimensions['C'].width = 14

    output.seek(0)
    return output
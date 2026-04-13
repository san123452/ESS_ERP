import os
import random
from PIL import Image, ImageDraw, ImageFont

# ── Windows 폰트 설정 ──────────────────────────────────────────
WINDOWS_FONT_REGULAR = "C:/Windows/Fonts/malgun.ttf"  # 맑은 고딕 Regular
WINDOWS_FONT_BOLD    = "C:/Windows/Fonts/malgunbd.ttf" # 맑은 고딕 Bold

# ── DB 거래처 데이터 ─────────────────────────────────────────
VENDORS_IN = ["(주) 가야", "주식회사 한빛네트워크", "(주) 조선", "(주) 시너지네트워크", "(유) 제나", "유한회사 첨단스타반도체", "(유) 라온코어시스템", "(주) 종합"]
VENDORS_OUT = ["(유) 마음", "(주) 가야고려상사", "(유) 종합모두그룹", "유한회사 이노"]
VENDORS_BOTH = ["(주) 인포뷰티", "유한회사 마루", "(유) 가람네오전자", "(유) 나루라온에이아이", "유한회사 고려시스템즈", "(주) 가온센터", "(주) 마루국민유통", "주식회사 네오"]

# ── 품목 데이터 ─────────────────────────────────────────
ITEMS = [
    {"code": "F-ESS-500",  "name": "에너지저장모듈 F-ESS-500",  "unit": "EA", "stock": 1500, "price": 35000},
    {"code": "H-CELL-100", "name": "수소셀 어셈블리 H-CELL-100","unit": "EA", "stock":  300, "price": 12000},
    {"code": "R-ANODE",    "name": "레독스 음극재 R-ANODE",      "unit": "KG", "stock": 5000, "price":   500},
    {"code": "R-CATHODE",  "name": "레독스 양극재 R-CATHODE",    "unit": "KG", "stock": 2000, "price":  1200},
]

OUR_COMPANY, OUR_BIZ_NO = "(주)에너지솔루션", "123-45-67890"
OUR_ADDR = "서울특별시 강남구 테헤란로 123, 에너지빌딩 15층"
OUR_TEL, OUR_FAX = "02-1234-5678", "02-1234-5679"
COLOR_WHITE, COLOR_TEXT = (255, 255, 255), (30, 30, 30)

# ── 유틸리티 함수 ────────────────────────────────────────────
def load_font(size, bold=False):
    path = WINDOWS_FONT_BOLD if bold else WINDOWS_FONT_REGULAR
    try: return ImageFont.truetype(path, size)
    except:
        try: return ImageFont.truetype("arial.ttf", size)
        except: return ImageFont.load_default()

def draw_rect(d, x1, y1, x2, y2, fill=None, outline=None, width=1):
    d.rectangle([x1, y1, x2, y2], fill=fill, outline=outline, width=width)

def draw_text_center(d, text, x1, y1, x2, y2, font, color=COLOR_TEXT):
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text((x1 + (x2 - x1 - tw) // 2, y1 + (y2 - y1 - th) // 2), text, fill=color, font=font)

def draw_text_right(d, text, x1, y1, x2, y2, font, color=COLOR_TEXT, pad=8):
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text((x2 - tw - pad, y1 + (y2 - y1 - th) // 2), text, fill=color, font=font)

def fmt_number(n): return f"{n:,}"

# ══════════════════════════════════════════════════════════════
#  발주서 (Purchase Order) 생성 - 생략 없는 풀버전
# ══════════════════════════════════════════════════════════════
def create_po(filename, order_date="2025-03-23", delivery_date="2025-04-15", order_no="PO-20250323-0001"):
    vendor = random.choice(VENDORS_IN + VENDORS_BOTH)
    selected = random.sample(ITEMS, random.randint(2, 3))
    order_items = [{**item, "qty": (q := random.choice([5, 10, 20, 50, 100])), "amount": q * item["price"]} for item in selected]
    total_supply = sum(i["amount"] for i in order_items)
    total_vat, total_amount = int(total_supply * 0.1), total_supply + int(total_supply * 0.1)

    W, H = 900, 1100
    img = Image.new("RGB", (W, H), COLOR_WHITE)
    d = ImageDraw.Draw(img)

    # 모든 폰트 변수 선언 (노란 물결 방지)
    f_title, f_sub, f_info = load_font(36, True), load_font(13), load_font(13)
    f_lbl, f_val, f_sect = load_font(12, True), load_font(11), load_font(13, True)
    f_col, f_cell = load_font(12, True), load_font(11)
    f_tot_lbl, f_tot_val = load_font(13, True), load_font(14, True)
    f_seal, f_note, f_note_val, f_foot = load_font(11, True), load_font(12, True), load_font(12), load_font(11)

    for gx in range(0, W, 40): d.line([(gx, 0), (gx, H)], fill=(245, 246, 248), width=1)
    for gy in range(0, H, 40): d.line([(0, gy), (W, gy)], fill=(245, 246, 248), width=1)

    draw_rect(d, 0, 0, W, 70, fill=(30, 60, 120))
    draw_text_center(d, "발  주  서", 0, 0, W, 70, f_title, COLOR_WHITE)
    draw_text_center(d, "PURCHASE ORDER", 0, 70, W, 90, f_sub, (100, 130, 180))

    y = 95
    draw_rect(d, 30, y, W-30, y+28, fill=(235, 240, 252), outline=(160, 175, 200), width=1)
    d.text((45, y+7), f"발주번호 : {order_no}", fill=(20, 40, 90), font=f_info)
    d.text((W-200, y+7), f"작성일자 : {order_date}", fill=(20, 40, 90), font=f_info)

    # 정보 블록
    y += 35
    block_h, mid_x = 130, W // 2
    draw_rect(d, 30, y, mid_x-5, y+block_h, fill=(248, 249, 251), outline=(160, 175, 200), width=1)
    d.text((40, y+8), "수  신  처", fill=(30, 60, 120), font=f_sect)
    for i, (l, v) in enumerate([("상호(법인명)", OUR_COMPANY), ("사업자번호", OUR_BIZ_NO), ("주      소", OUR_ADDR[:18]+"..."), ("전  화  번호", OUR_TEL)]):
        d.text((40, y+35+i*23), l, fill=(80, 90, 110), font=f_lbl)
        d.text((165, y+35+i*23), v, fill=COLOR_TEXT, font=f_val)

    draw_rect(d, 455, y, W-30, y+130, fill=(248, 249, 251), outline=(160, 175, 200), width=1)
    d.text((465, y+8), "공  급  자", fill=(150, 30, 30), font=f_sect)
    biz_fake = f"{random.randint(100,999)}-{random.randint(10,99)}-{random.randint(10000,99999)}"
    for i, (l, v) in enumerate([("상호(법인명)", vendor), ("사업자번호", biz_fake), ("납  기  일자", delivery_date), ("결제  방법", "전자결제")]):
        d.text((465, y+35+i*23), l, fill=(80, 90, 110), font=f_lbl)
        d.text((590, y+35+i*23), v, fill=COLOR_TEXT, font=f_val)

    # 테이블 헤더 (9컬럼 유지)
    y += 145
    cols = [("No", 35, "center"), ("품  목  명", 240, "left"), ("품목코드", 120, "center"), ("단위", 50, "center"), ("수량", 65, "right"), ("단가", 95, "right"), ("공급가액", 120, "right"), ("비고", 40, "center")]
    draw_rect(d, 30, y, 870, y+36, fill=(50, 90, 160), outline=(160, 175, 200), width=1)
    cx = 30
    for hdr, cw, _ in cols:
        draw_text_center(d, hdr, cx, y, cx+cw, y+36, f_col, COLOR_WHITE)
        cx += cw

    y += 36
    for i, item in enumerate(order_items):
        draw_rect(d, 30, y, 870, y+32, fill=COLOR_WHITE if i%2==0 else (245, 248, 255), outline=(160, 175, 200), width=1)
        # ★ 수정 포인트: No, 품 명 명 같은 텍스트가 아니라 실제 변수(item["name"] 등)를 row_vals에 담음
        row_vals = [str(i+1), item["name"], item["code"], item["unit"], fmt_number(item["qty"]), fmt_number(item["price"]), fmt_number(item["amount"]), ""]
        cx = 30
        for j, val in enumerate(row_vals):
            cw, align = cols[j][1], cols[j][2]
            if align == "center": draw_text_center(d, val, cx, y, cx+cw, y+32, f_cell)
            elif align == "right": draw_text_right(d, val, cx, y, cx+cw, y+32, f_cell)
            else: d.text((cx+6, y+7), val, fill=COLOR_TEXT, font=f_cell)
            cx += cw
        y += 32

    # 합계
    y += 40
    for j, (lbl, val) in enumerate([("공급가액 합계", fmt_number(total_supply)+" 원"), ("부  가  세  액", fmt_number(total_vat)+" 원"), ("합  계  금  액", fmt_number(total_amount)+" 원")]):
        draw_rect(d, W-370, y, W-30, y+34, fill=(220, 232, 255) if j<2 else (180, 205, 255), outline=(160, 175, 200), width=1)
        d.text((W-355, y+9), lbl, fill=(30, 60, 120), font=f_tot_lbl)
        draw_text_right(d, val, W-370, y, W-30, y+34, f_tot_val, (150, 20, 20))
        y += 34

    # 도장 결재란 (PO 복원)
    y += 20
    draw_rect(d, W-310, y, W-30, y+80, fill=(230, 240, 255), outline=(160, 175, 200), width=1)
    for k, s in enumerate(["담 당", "팀 장", "부 장"]):
        draw_text_center(d, s, W-310+k*93, y, W-310+(k+1)*93, y+20, f_seal, (30, 60, 120))
        draw_rect(d, W-310+k*93, y+20, W-310+(k+1)*93, y+80, fill=COLOR_WHITE, outline=(160, 175, 200))

    # 특기사항 (PO 복원)
    y += 95
    draw_rect(d, 30, y, W-30, y+70, fill=(252, 252, 255), outline=(160, 175, 200), width=1)
    d.text((40, y+8), "※ 특  기  사  항", fill=(30, 60, 120), font=f_note)
    d.text((40, y+30), "· 상기 품목을 정히 발주하오니 납품기일을 준수하여 주시기 바랍니다.", fill=(60, 60, 60), font=f_note_val)

    # 푸터 (PO 복원)
    draw_rect(d, 0, H-45, W, H, fill=(30, 60, 120))
    footer = f"{OUR_COMPANY}  |  사업자등록번호: {OUR_BIZ_NO}  |  TEL: {OUR_TEL}"
    draw_text_center(d, footer, 0, H-45, W, H, f_foot, (180, 200, 230))

    img.save(filename, dpi=(300, 300))
    print(f"✅ 발주서 완료: {filename}")

# ══════════════════════════════════════════════════════════════
#  수주서 (Sales Order) 생성 - 생략 없는 풀버전 (현재고 제거)
# ══════════════════════════════════════════════════════════════
def create_so(filename, order_date="2025-03-23", delivery_date="2025-04-01", order_no="SO-20250323-0349"):
    customer = random.choice(VENDORS_OUT + VENDORS_BOTH)
    selected = random.sample(ITEMS, random.randint(2, 3))
    order_items = [{**item, "qty": (q := random.choice([5, 10, 20, 50, 100])), "amount": q * item["price"]} for item in selected]
    total_supply = sum(i["amount"] for i in order_items)
    total_vat, total_amount = int(total_supply * 0.1), total_supply + int(total_supply * 0.1)

    W, H = 900, 1150
    img = Image.new("RGB", (W, H), COLOR_WHITE)
    d = ImageDraw.Draw(img)

    # 모든 폰트 변수 선언 (노란 물결 방지)
    f_title, f_sub, f_info = load_font(36, True), load_font(13), load_font(13)
    f_lbl, f_val, f_sect = load_font(12, True), load_font(11), load_font(13, True)
    f_col, f_cell = load_font(12, True), load_font(11)
    f_tot_lbl, f_tot_val = load_font(13, True), load_font(14, True)
    f_seal, f_note, f_note_val, f_foot = load_font(11, True), load_font(12, True), load_font(12), load_font(11)

    for gx in range(0, W, 40): d.line([(gx, 0), (gx, H)], fill=(245, 246, 248), width=1)
    for gy in range(0, H, 40): d.line([(0, gy), (W, gy)], fill=(245, 246, 248), width=1)

    hdr_color = (20, 100, 70)
    draw_rect(d, 0, 0, W, 70, fill=hdr_color)
    draw_text_center(d, "수  주  서", 0, 0, W, 70, f_title, COLOR_WHITE)
    draw_text_center(d, "SALES ORDER", 0, 70, W, 90, f_sub, (80, 160, 120))

    y = 95
    draw_rect(d, 30, y, W-30, y+28, fill=(235, 248, 242), outline=(160, 200, 180), width=1)
    d.text((45, y+7), f"수주번호 : {order_no}", fill=(20, 80, 50), font=f_info)
    d.text((W-180, y+7), f"작성일자 : {order_date}", fill=(20, 80, 50), font=f_info)

    y += 35
    block_h, mid_x = 135, W // 2
    draw_rect(d, 30, y, mid_x-5, y+block_h, fill=(240, 250, 245), outline=(160,200,180), width=1)
    d.text((40, y+8), "공  급  자", fill=hdr_color, font=f_sect)
    draw_rect(d, 30, y+28, mid_x-5, y+29, fill=(160,200,180))
    fields_left = [("상호(법인명)", OUR_COMPANY), ("사업자번호", OUR_BIZ_NO), ("주      소", OUR_ADDR[:18]+"..."), ("전  화  번호", OUR_TEL), ("납  기  일자", delivery_date)]
    for i, (lbl, val) in enumerate(fields_left):
        fy = y + 35 + i * 20
        d.text((40, fy), lbl, fill=(60, 100, 80), font=f_lbl)
        d.text((165, fy), val, fill=COLOR_TEXT, font=f_val)

    draw_rect(d, 455, y, W-30, y+135, fill=(240, 250, 245), outline=(160,200,180), width=1)
    d.text((465, y+8), "수  신  처 (고객사)", fill=(150, 30, 30), font=f_sect)
    biz_fake = f"{random.randint(100,999)}-{random.randint(10,99)}-{random.randint(10000,99999)}"
    for i, (l, v) in enumerate([("상호(법인명)", customer), ("사업자번호", biz_fake), ("납  기  일자", delivery_date), ("결  제  조건", "전자결제"), ("담  당  자", "박담당")]):
        d.text((465, y+35+i*20), l, fill=(60, 100, 80), font=f_lbl)
        d.text((590, y+35+i*20), v, fill=COLOR_TEXT, font=f_val)

    y += 150
    # ★ 수정 포인트: '현재고'를 빼고 컬럼을 재구성
    cols = [("No", 35, "center"), ("품  목  명", 240, "left"), ("품목코드", 120, "center"), ("단위", 50, "center"), ("수량", 65, "right"), ("단가", 95, "right"), ("공급가액", 120, "right"), ("비고", 40, "center")]
    draw_rect(d, 30, y, 870, y+36, fill=(40, 120, 80), outline=(100,160,120), width=1)
    cx = 30
    for hdr, cw, _ in cols:
        draw_text_center(d, hdr, cx, y, cx+cw, y+36, f_col, COLOR_WHITE)
        cx += cw

    y += 36
    for i, item in enumerate(order_items):
        draw_rect(d, 30, y, 870, y+32, fill=COLOR_WHITE if i%2==0 else (240, 250, 244), outline=(160, 200, 175), width=1)
        # ★ 데이터 매핑 수정: 현재고 자리에 수량을 넣음
        row_vals = [str(i+1), item["name"], item["code"], item["unit"], fmt_number(item["qty"]), fmt_number(item["price"]), fmt_number(item["amount"]), ""]
        cx = 30
        for j, val in enumerate(row_vals):
            # cols 리스트의 크기에 맞춰서 값을 매핑 (비고란 데이터 누락 방지)
            if j < len(cols):
                cw, align = cols[j][1], cols[j][2]
                if align == "center": draw_text_center(d, val, cx, y, cx+cw, y+32, f_cell)
                elif align == "right": draw_text_right(d, val, cx, y, cx+cw, y+32, f_cell)
                else: d.text((cx+6, y+7), val, fill=COLOR_TEXT, font=f_cell)
                cx += cw
        y += 32

    y += 40
    for j, (lbl, val) in enumerate([("공급가액 합계", fmt_number(total_supply)+" 원"), ("부  가  세  액", fmt_number(total_vat)+" 원"), ("합  계  금  액", fmt_number(total_amount)+" 원")]):
        draw_rect(d, W-370, y, W-30, y+34, fill=(210, 240, 225) if j<2 else (160, 220, 190), outline=(140,190,160), width=1)
        d.text((W-355, y+9), lbl, fill=hdr_color, font=f_tot_lbl)
        draw_text_right(d, val, W-370, y, W-30, y+34, f_tot_val, (150, 20, 20))
        y += 34

    # ★ 수주서 담당 입력란 복원!
    y += 20
    draw_rect(d, W-310, y, W-30, y+80, fill=(235, 248, 242), outline=(140,190,160), width=1)
    for k, s in enumerate(["담 당", "팀 장", "부 장"]):
        draw_text_center(d, s, W-310+k*93, y, W-310+(k+1)*93, y+20, f_seal, hdr_color)
        draw_rect(d, W-310+k*93, y+20, W-310+(k+1)*93, y+80, fill=COLOR_WHITE, outline=(140,190,160))

    # ★ 수주서 특기사항 복원!
    y += 95
    draw_rect(d, 30, y, W-30, y+70, fill=(248, 253, 250), outline=(140,190,160), width=1)
    d.text((40, y+8), "※ 특  기  사  항", fill=hdr_color, font=f_note)
    d.text((40, y+30), "· 상기 품목을 정히 수주하였음을 확인합니다.", fill=(60,60,60), font=f_note_val)

    # ★ 맨 아래 회사 인포 복원!
    draw_rect(d, 0, H-45, W, H, fill=hdr_color)
    footer = f"{OUR_COMPANY}  |  사업자번호: {OUR_BIZ_NO}  |  TEL: {OUR_TEL}"
    draw_text_center(d, footer, 0, H-45, W, H, f_foot, (160, 220, 190))

    img.save(filename, dpi=(300, 300))
    print(f"✅ 수주서 완료: {filename}")

if __name__ == "__main__":
    random.seed(42)
    cur = os.path.dirname(os.path.abspath(__file__))
    create_po(os.path.join(cur, "sample_po_test.png"))
    create_so(os.path.join(cur, "sample_so_test.png"))
    print("\n🎉 데이터 누락 및 현재고 이슈 해결! 풀버전으로 다시 실행해 보세요.")
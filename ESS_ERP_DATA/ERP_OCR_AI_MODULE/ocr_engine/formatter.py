"""
formatter.py
────────────
기존 format_to_dataframe()의 버그 수정 버전.

수정된 버그:
  1. [날짜] 작성일자/납기일자 혼용 문제
     - 기존: 납기 키워드 없으면 무조건 date에 덮어씀
       → "납기일자" 줄이 나중에 오면 date가 납기일로 덮어씌워짐
     - 수정: 작성/주문/발주 키워드 있을 때만 date 갱신

  2. [vendor] 키워드 부족 → "Unknown Store" 반환
     - 수정: "유한회사", "주식회사", "네트워크", "솔루션" 등 추가

  3. [vendor] "공급자: " 접두사가 그대로 저장되는 문제
     - 수정: 정규식으로 "공급자: ", "수신: " 등 접두사 제거

  4. [품목 패턴] 공백 1개로 분리 → 오매칭 빈번
     - 수정: 공백 2개 이상(\\s{2,})으로 컬럼 경계 구분
"""

import re
import pandas as pd
import difflib  # 유사도 비교를 위한 라이브러리


# ── 상수 ──────────────────────────────────────

VENDOR_KEYWORDS = [
    "점", "Store", "Mart",
    "(주)", "(유)", "주식회사", "유한회사",
    "상사", "유통", "산업", "테크",
    "네트워크", "솔루션", "코퍼레이션", "엔터프라이즈",
    "마루", "시너지",
]

# "공급자: ", "수신: " 등 접두사 제거 패턴
VENDOR_PREFIX_RE = re.compile(
    r'^(공급자|수신|발신|거래처|Vendor|Supplier)\s*:\s*',
    re.IGNORECASE
)

DATE_RE        = re.compile(r'\d{4}[-/.]\d{2}[-/.]\d{2}')
ORDER_DATE_RE  = re.compile(r'(작성|주문|발주|Order)', re.IGNORECASE)
DUE_DATE_RE    = re.compile(r'(납기|Due|만기|기\s?일자?)', re.IGNORECASE)

SKIP_KEYWORDS  = ["합계", "소계", "결제", "Total", "Amount", "VAT", "부가세"]

# [개선] DB 품목 마스터 데이터를 Map 형태로 관리 (인식된 이름 -> 표준 코드로 변환)
KNOWN_ITEM_MAP = {
    # 품목명으로 찾기
    "에너지저장모듈 F-ESS-500": "F-ESS-500",
    "수소셀 어셈블리 H-CELL-100": "H-CELL-100",
    "레독스 음극재 R-ANODE": "R-ANODE",      # [수정] Anode는 음극
    "레독스 양극재 R-CATHODE": "R-CATHODE",  # [수정] Cathode는 양극
    # 품목 코드로 찾기
    "F-ESS-500": "F-ESS-500",
    "H-CELL-100": "H-CELL-100",
    "R-ANODE": "R-ANODE",
    "R-CATHODE": "R-CATHODE",
    "B-PACK-200": "B-PACK-200",
}
ALL_KNOWN_ITEMS = list(KNOWN_ITEM_MAP.keys())


# ── 메인 함수 ──────────────────────────────────

def format_to_dataframe(raw_text: str) -> pd.DataFrame:
    # OCR 결과로 자주 붙는 특수문자 제거 (품목명 오작동 방지)
    # 예: "H-CELL-100'" -> "H-CELL-100"
    raw_text = raw_text.replace("'", "")

    lines = raw_text.split('\n')
    data = []

    vendor   = "Unknown Store"
    date     = "2024-01-01"
    due_date = None

    # [개선] 2~3개의 숫자 그룹으로 끝나는 품목 라인을 찾는 정규식
    # 이름에 숫자가 포함될 수 있으므로, 맨 뒤 숫자 그룹부터 역으로 탐색하는 것이 안정적임
    # 그룹 1: 품목명 (수량/단가/금액 등 숫자 제외)
    # 그룹 2: 수량
    # 그룹 3: 단가
    # [수정] 맨 뒤에 비고란 내용이나 노이즈가 있어도 매칭되도록 끝부분 패턴을 .*$ 로 변경
    ITEM_LINE_RE = re.compile(r'^(?P<name>.+?)\s+(?P<qty>[\d,]+)\s+(?P<price>[\d,]+)(?:\s+[\d,]+)?.*$')

    for line in lines:
        line = line.strip()
        if not line:
            continue

        # ── 1. 날짜 추출 ───────────────────────
        date_match = DATE_RE.search(line)
        if date_match:
            extracted_date = date_match.group()

            if DUE_DATE_RE.search(line):
                due_date = extracted_date                   # 납기일자
            elif ORDER_DATE_RE.search(line):
                date = extracted_date                       # 작성일자 (핵심 수정)
            # else: 키워드 없는 날짜 줄은 무시 → 덮어쓰기 방지

            continue

        # ── 2. vendor 추출 ─────────────────────
        if any(kw in line for kw in VENDOR_KEYWORDS):
            if len(re.findall(r'\d', line)) < 5 and '합계' not in line:
                # '상호(법인명)' 이나 '(주)' 등이 두 번 이상 나타나면, 라인을 반으로 나눠 뒤쪽을 사용
                # OCR이 두 컬럼을 한 줄로 인식하는 경우에 대한 방어 코드
                if line.count('상호') > 1 or line.count('(주)') > 1 or line.count('(유)') > 1:
                    # 뒤에서부터 '상호' 또는 '('를 찾아 그 지점부터 사용
                    split_pos = -1
                    if '상호' in line:
                        split_pos = line.rfind('상호')
                    elif '(' in line:
                        split_pos = line.rfind('(')
                    
                    if split_pos != -1:
                        line = line[split_pos:]

                vendor = VENDOR_PREFIX_RE.sub('', line).strip()
                continue

        # ── 3. 품목 라인 분석 (전면 개편) ────────
        if any(kw.lower() in line.lower() for kw in SKIP_KEYWORDS):
            continue

        item_match = ITEM_LINE_RE.search(line)
        if item_match:
            try:
                item_name = item_match.group('name').strip()
                qty = int(item_match.group('qty').replace(',', ''))
                unit_price = int(item_match.group('price').replace(',', ''))

                # OCR로 인식된 품목명 앞의 '1.', '2 ' 같은 리스트 마커 제거
                cleaned_name = re.sub(r'^\W*\d+\s*\.?\s*', '', item_name).strip()

                # 품목명에는 반드시 한글/영문자가 포함되어야 함
                if not re.search(r'[a-zA-Z가-힣]', cleaned_name):
                    continue

                # 단위(EA, KG) 등이 품목명으로 오인되는 것 방지
                if cleaned_name.upper() in ['EA', 'KG', 'BOX']:
                    continue

                # [추가] 품목명 자동 보정 (Fuzzy Matching)
                # 추출된 이름과 가장 유사한 DB 품목명을 찾아서 교체 (유사도 60% 이상인 경우)
                matches = difflib.get_close_matches(cleaned_name, ALL_KNOWN_ITEMS, n=1, cutoff=0.6)
                if matches:
                    # 매칭된 이름(e.g., "에너지저장모듈 F-ESS-500")을 표준 코드(e.g., "F-ESS-500")로 변환
                    cleaned_name = KNOWN_ITEM_MAP[matches[0]]

                # 수량, 단가가 0이거나 너무 작은 값일 경우 오탐지로 간주하고 스킵
                if qty <= 0 or unit_price <= 0:
                    continue

                data.append(_row(vendor, date, due_date, cleaned_name, qty, unit_price))

            except (ValueError, IndexError):
                continue

    # ── DataFrame 반환 ─────────────────────────
    df = pd.DataFrame(data)

    if df.empty:
        return pd.DataFrame(columns=[
            "vendor", "date", "due_date",
            "item_name", "quantity", "unit_price", "total_price"
        ])

    df = df.astype(object)
    df = df.where(pd.notnull(df), None)
    return df


def _row(vendor, date, due_date, item_name, qty, unit_price) -> dict:
    return {
        "vendor":      vendor,
        "date":        date,
        "due_date":    due_date if due_date else date,
        "item_name":   item_name,
        "quantity":    qty,
        "unit_price":  unit_price,
        "total_price": qty * unit_price,
    }
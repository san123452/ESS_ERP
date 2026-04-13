import random
from collections import deque
from datetime import datetime, timedelta

"""
test_analytics.py v5
====================
[3번 수정] SQL 파싱 완전 제거 → 루프에서 직접 리스트 구축
  - sales_list, production_list, raw_price_ts 를 시뮬레이션 루프 안에서 직접 append
  - SQL INSERT는 DB 저장용으로만 사용, 검증 시 파싱 불필요
  - 쉼표/공백 포함 데이터에 의한 IndexError/ValueError 원천 차단

[4번 수정] 리드타임-생산 Deadlock 완화
  - Phase3 리드타임 상한을 2배(최대 20일) → 1.5배(최대 15일)로 제한
  - 생산 시도 시 '당일 재고'가 부족해도 pending 입고 예정량 포함해서 판단
  - 생산 대기(WAIT) 상태로 하루 더 버팀 (즉시 실패 처리 제거)

[5번 수정] 재고 회복 탄력성 강화
  - REORDER_POINT 상향 (안전재고 수준으로)
  - ORDER_QTY 증량 (1회 발주량 +30%)
  - 발주 확률 70% → 85% (더 적극적인 재발주)
  - 재고 0 도달 시 긴급 발주 즉시 트리거 (리드타임 1~3일 단축)
"""

# ── 기본 설정 ──────────────────────────────────────────────────
START_DATE   = datetime.now() - timedelta(days=730)
END_DATE     = datetime.now()
PHASE2_START = START_DATE + timedelta(days=180) 
PHASE3_START = datetime(2025, 1, 1)   # 25년 1분기~3분기 (위기기 시작)
PHASE4_START = datetime(2025, 10, 1)  # 25년 4분기~ (회복 및 안정기 시작)

SALES_EMP = '12345'
MGMT_EMP  = '2026001'

# ── 품목 마스터 ────────────────────────────────────────────────
BASE_PRICES = {
    'F-ESS-500':   300000000,
    'H-RACK-50':    28000000,
    'H-MOD-10':       550000,
    'H-CELL-100':      50000,
    'R-CATHODE':       15000,
    'R-ANODE':          8000,
    'R-SEPARATOR':      1200,
    'R-ELECTRO':        4500,
    'R-AL-CAN':          500,
    'R-BMS-PCB':      120000,
}

BOM = {
    'F-ESS-500':  [('H-RACK-50',   10)],
    'H-RACK-50':  [('H-MOD-10',    50), ('R-BMS-PCB', 1)],
    'H-MOD-10':   [('H-CELL-100',  10)],
    'H-CELL-100': [('R-CATHODE',    2), ('R-ANODE', 1), ('R-SEPARATOR', 5),
                   ('R-ELECTRO',    1), ('R-AL-CAN', 1)],
}

RAW_ITEMS  = [cd for cd in BASE_PRICES if cd.startswith('R-')]
SELL_ITEMS = ['F-ESS-500', 'H-RACK-50']

# ① 초기 재고 — 안전재고 수준 (타이트하게)
INIT_STOCK = {
    'F-ESS-500':   15, 'H-RACK-50':  150, 'H-MOD-10':  1500,
    'H-CELL-100': 3000, 'R-CATHODE': 8000, 'R-ANODE':  5000,
    'R-SEPARATOR': 4000, 'R-ELECTRO': 3000, 'R-AL-CAN': 6000,
    'R-BMS-PCB':  1500,
}

# [5번] REORDER_POINT 상향 + ORDER_QTY 증량
REORDER_POINT = {
    'R-CATHODE':   5000, 'R-ANODE':   3500, 'R-SEPARATOR': 2500,
    'R-ELECTRO':   2000, 'R-AL-CAN':  3500, 'R-BMS-PCB':   800,
}
ORDER_QTY = {
    'R-CATHODE':  10000, 'R-ANODE':   8000, 'R-SEPARATOR': 7000,
    'R-ELECTRO':   5500, 'R-AL-CAN':  9000, 'R-BMS-PCB':  2500,
}

# ── 거래처 페르소나 ────────────────────────────────────────────
VENDORS_IN  = [f"AC{i:03d}" for i in range(10, 30)]
VENDORS_OUT = [f"AC{i:03d}" for i in range(30, 60)]

VENDOR_BAD_RATE = {
    **{f"AC{i:03d}": 0.05  for i in range(10, 16)},
    **{f"AC{i:03d}": 0.015 for i in range(16, 30)},
}
HIGH_CANCEL_VENDORS = {f"AC{i:03d}" for i in range(35, 41)}


# ── Phase 헬퍼 ────────────────────────────────────────────────
def get_phase(dt):
    if dt >= PHASE4_START: return 4
    if dt >= PHASE3_START: return 3
    if dt >= PHASE2_START: return 2
    return 1

def get_raw_price(item_cd, dt):
    base  = BASE_PRICES[item_cd]
    phase = get_phase(dt)
    if phase == 1:   m = random.uniform(0.96, 1.04)
    elif phase == 2: m = random.uniform(1.02, 1.10)
    elif phase == 3: m = random.uniform(1.18, 1.35) # 위기기: 원가 대폭 폭등
    else:            m = random.uniform(0.95, 1.03) # 회복기: 원가 안정화
    return int(base * m)

def get_cancel_rate(vendor, dt):
    phase = get_phase(dt)
    if vendor in HIGH_CANCEL_VENDORS:
        if phase == 3: return 0.22 # 위기기: 취소율 급증
        if phase == 4: return 0.05 # 회복기: 취소율 안정
        return 0.06
    return 0.02

def get_emp_and_sell_price(item_cd, phase):
    if phase == 3 and random.random() < 0.6:
        # 위기기: 덤핑 판매로 인한 가격 하락
        return SALES_EMP, int(BASE_PRICES[item_cd] * random.uniform(0.85, 0.91))
    elif phase == 2:
        return MGMT_EMP,  int(BASE_PRICES[item_cd] * random.uniform(0.98, 1.03))
    elif phase == 4:
        # 회복기: 제값 받기 시작 + 프리미엄 전략
        return MGMT_EMP,  int(BASE_PRICES[item_cd] * random.uniform(1.02, 1.07))
    else:
        return MGMT_EMP,  int(BASE_PRICES[item_cd] * random.uniform(0.99, 1.01))


# ── FIFO 큐 ────────────────────────────────────────────────────
fifo_queue: dict = {item: deque() for item in BASE_PRICES}

def fifo_in(item_cd, qty, unit_price):
    fifo_queue[item_cd].append((qty, unit_price))

def fifo_cost(item_cd, qty):
    total_cost = 0
    remaining  = qty
    q = fifo_queue[item_cd]
    while remaining > 0 and q:
        lot_qty, lot_price = q[0]
        take = min(remaining, lot_qty)
        total_cost += take * lot_price
        remaining  -= take
        if take == lot_qty: q.popleft()
        else:               q[0] = (lot_qty - take, lot_price)
    if remaining > 0:
        total_cost += remaining * BASE_PRICES[item_cd]
    return total_cost


# ── 상태 변수 ──────────────────────────────────────────────────
current_stock   = dict(INIT_STOCK)
sql_statements  = []
order_counter   = 1
work_counter    = 1
stockout_events = []
stuck_orders    = []

# [3번] 검증용 리스트 — 루프에서 직접 구축 (SQL 파싱 불필요)
_sales_list      = []   # analyzer에 넘길 판매 데이터
_production_list = []   # analyzer에 넘길 생산 실적
_raw_price_ts    = {}   # {item_cd: [(dt, unit_price)]} — FIFO 원가 계산용

# pending: [(arrive_dt, item_cd, qty, unit_price, po_no)]
pending_orders = []

# [4번] 생산 대기 큐: 재고 부족 시 하루 대기 후 재시도
# {parent: (work_qty, wk_no, due_wk, bad_qty, good_qty, children)}
pending_production = {}

# FIFO 초기 재고 등록
for item, qty in INIT_STOCK.items():
    if qty > 0:
        fifo_in(item, qty, BASE_PRICES[item])


def add_sql(q):
    sql_statements.append(q)

def log_stock(item_cd, inout, qty, ref_no, dt):
    before = current_stock[item_cd]
    after  = before + qty if inout == 'IN' else before - qty
    current_stock[item_cd] = after
    add_sql(
        f"INSERT INTO tb_item_log "
        f"(ITEM_CD, INOUT_TYPE, QTY, BEFORE_QTY, AFTER_QTY, REF_NO, EMP_ID, REG_DT) "
        f"VALUES ('{item_cd}', '{inout}', {qty}, {before}, {after}, "
        f"'{ref_no}', '{MGMT_EMP}', '{dt.strftime('%Y-%m-%d %H:%M:%S')}');"
    )

def pending_stock_incoming(item_cd):
    """[4번] 아직 미도착이지만 발주 완료된 수량 합산"""
    return sum(qty for _, icd, qty, _, _ in pending_orders if icd == item_cd)


# ── 메인 시뮬레이션 ────────────────────────────────────────────
print("🚀 ESS ERP v5 시뮬레이션 시작...")

current_dt = START_DATE
while current_dt <= END_DATE:
    phase = get_phase(current_dt)

    # ── 리드타임 입고 처리 ────────────────────────────────────
    arrived = [p for p in pending_orders if p[0] <= current_dt]
    for arrive_dt, item_cd, qty, unit_price, po_no in arrived:
        log_stock(item_cd, 'IN', qty, po_no, current_dt)
        fifo_in(item_cd, qty, unit_price)
    pending_orders = [p for p in pending_orders if p[0] > current_dt]

    # ── [5번] 재고 임계치 기반 발주 ──────────────────────────
    for item_cd in RAW_ITEMS:
        stock_now    = current_stock[item_cd]
        stock_future = stock_now + pending_stock_incoming(item_cd)

        # 긴급 발주: 재고 0 또는 임계치의 50% 이하
        is_emergency = stock_now == 0 or stock_now < REORDER_POINT[item_cd] * 0.5
        is_reorder   = stock_future <= REORDER_POINT[item_cd]

        if not (is_emergency or is_reorder):
            continue

        # [5번] 발주 확률: 일반 85%, 긴급 100%
        if not is_emergency and random.random() > 0.85:
            continue

        vendor     = random.choice(VENDORS_IN)
        po_no      = f"PO-{current_dt.strftime('%Y%m%d')}-{order_counter:03d}"
        qty        = ORDER_QTY[item_cd] + random.randint(-300, 300)
        unit_price = get_raw_price(item_cd, current_dt)
        supply_amt = qty * unit_price
        vat_amt    = int(supply_amt * 0.1)

        # [4번] 리드타임 상한 완화: 일반 3~10일, Phase3 최대 1.5배(15일)
        lead_days = random.randint(3, 10)
        if phase == 3 and random.random() < 0.3:
            lead_days = int(lead_days * 1.5)
        # [5번] 긴급 발주는 리드타임 단축
        if is_emergency:
            lead_days = max(1, lead_days - 2)

        arrive_dt_po = current_dt + timedelta(days=lead_days)
        due_date     = (current_dt + timedelta(days=7)).strftime('%Y-%m-%d')
        po_status    = 'CANCEL' if random.random() < 0.04 else 'DONE'

        add_sql(
            f"INSERT INTO tb_order "
            f"(ORDER_NO, ORDER_TYPE, ACCT_CD, EMP_ID, ORDER_DATE, DUE_DATE, STATUS) "
            f"VALUES ('{po_no}', 'BUY', '{vendor}', '{MGMT_EMP}', "
            f"'{current_dt.strftime('%Y-%m-%d %H:%M:%S')}', '{due_date}', '{po_status}');"
        )
        add_sql(
            f"INSERT INTO tb_order_detail "
            f"(ORDER_NO, ITEM_CD, QTY, UNIT_PRICE, SUPPLY_AMT, VAT_AMT, AMT) "
            f"VALUES ('{po_no}', '{item_cd}', {qty}, {unit_price}, "
            f"{supply_amt}, {vat_amt}, {supply_amt + vat_amt});"
        )

        if po_status == 'DONE':
            pending_orders.append((arrive_dt_po, item_cd, qty, unit_price, po_no))
            # [3번] 원가 시계열 직접 기록
            _raw_price_ts.setdefault(item_cd, []).append((current_dt, unit_price))

        order_counter += 1

    # ── [2번] 생산 대기 큐 처리 — 재고 회복 시 재시도 ─────────
    for queue_key in list(pending_production.keys()):
        retry_queue = pending_production[queue_key]
        still_waiting = []
        for expire_dt, p_parent, p_work_qty, p_wk_no, p_due_wk in retry_queue:
            if current_dt > expire_dt:
                # 만료: 포기 처리 (이미 stockout_events에 기록됨)
                continue
            p_children   = BOM[p_parent]
            p_can_produce = all(
                current_stock.get(c, 0) >= p_work_qty * r for c, r in p_children
            )
            if p_can_produce:
                # 재고 회복 → 지연 생산 실행
                p_bad_rate  = 0.02
                ph = get_phase(current_dt)
                if ph == 3:
                    p_bad_rate = min(p_bad_rate * 1.8, 0.12)
                elif ph == 4:
                    p_bad_rate = 0.015
                p_bad_qty   = max(0, int(p_work_qty * p_bad_rate))
                p_good_qty  = max(0, p_work_qty - p_bad_qty)
                p_mat_cost  = 0
                for child_cd, req in p_children:
                    total_req = p_work_qty * req
                    log_stock(child_cd, 'OUT', total_req, p_wk_no, current_dt)
                    p_mat_cost += fifo_cost(child_cd, total_req)
                p_unit_cost = int(p_mat_cost / p_work_qty) if p_work_qty > 0 else BASE_PRICES[p_parent]
                add_sql(
                    f"INSERT INTO tb_work_perf "
                    f"(WORK_NO, GOOD_QTY, BAD_QTY, PERF_DATE, EMP_ID) "
                    f"VALUES ('{p_wk_no}', {p_good_qty}, {p_bad_qty}, "
                    f"'{current_dt.strftime('%Y-%m-%d %H:%M:%S')}', '{MGMT_EMP}');"
                )
                log_stock(p_parent, 'IN', p_good_qty, p_wk_no, current_dt)
                fifo_in(p_parent, p_good_qty, p_unit_cost)
                _raw_price_ts.setdefault(p_parent, []).append((current_dt, p_unit_cost))
                _production_list.append({"GOOD_QTY": p_good_qty, "BAD_QTY": p_bad_qty, "itemCd": p_parent})
            else:
                still_waiting.append((expire_dt, p_parent, p_work_qty, p_wk_no, p_due_wk))
        # [test 3번] 만료 항목 제거 + 큐 크기 상한(품목당 최대 5건) 메모리 방어
        pending_production[queue_key] = still_waiting[-5:]

    # ── 생산 ─────────────────────────────────────────────────
    prod_order = ['H-CELL-100', 'H-MOD-10', 'H-RACK-50', 'F-ESS-500']
    chance_map = {'H-CELL-100': 0.7, 'H-MOD-10': 0.5, 'H-RACK-50': 0.35, 'F-ESS-500': 0.2}

    for parent in prod_order:
        if random.random() >= chance_map[parent]:
            continue

        work_qty = random.randint(5, 15) if parent == 'F-ESS-500' else random.randint(30, 150)
        wk_no    = f"WK-{current_dt.strftime('%Y%m%d')}-{work_counter:03d}"
        due_wk   = (current_dt + timedelta(days=3)).strftime('%Y-%m-%d')
        children = BOM[parent]

        # [4번] 재고 판단: 당일 재고 + 1일 내 도착 예정량 포함
        tomorrow    = current_dt + timedelta(days=1)
        soon_arrive = {
            icd: sum(q for adt, icd2, q, _, _ in pending_orders
                     if icd2 == icd and adt <= tomorrow)
            for icd, _ in children
        }
        effective_stock = {
            c: current_stock.get(c, 0) + soon_arrive.get(c, 0)
            for c, _ in children
        }
        can_produce = all(effective_stock[c] >= work_qty * r for c, r in children)

        if not can_produce:
            shortage = [(c, work_qty*r - effective_stock[c])
                        for c, r in children if effective_stock[c] < work_qty*r]
            stockout_events.append((current_dt, parent, shortage))

            # [2번] 생산 대기 큐 등록 — 최대 3일간 대기 후 재시도
            # 이미 대기 중인 동일 품목이 없을 때만 등록 (중복 방지)
            already_waiting = any(
                p_parent == parent
                for _, p_parent, _, _, _ in pending_production.get(parent, [])
            ) if hasattr(pending_production, 'get') else False

            queue_key = parent
            if queue_key not in pending_production:
                pending_production[queue_key] = []
            # 대기 만료일: 오늘로부터 3일
            expire_dt = current_dt + timedelta(days=3)
            pending_production[queue_key].append(
                (expire_dt, parent, work_qty, wk_no, due_wk)
            )
            work_counter += 1
            continue

        raw_vendor = random.choice(VENDORS_IN)
        bad_rate   = VENDOR_BAD_RATE.get(raw_vendor, 0.02)
        if phase == 3:
            bad_rate = min(bad_rate * 1.8, 0.12)
        elif phase == 4:
            bad_rate = max(0.01, bad_rate * 0.7)
        bad_qty  = max(0, int(work_qty * bad_rate + random.gauss(0, 0.5)))
        good_qty = max(0, work_qty - bad_qty)

        # ③ 미결 작업지시 5% PROG
        wk_status = 'PROG' if random.random() < 0.05 else 'DONE'
        if wk_status == 'PROG':
            stuck_orders.append((current_dt, wk_no, parent))

        add_sql(
            f"INSERT INTO tb_work_order "
            f"(WORK_NO, ITEM_CD, WORK_QTY, EMP_ID, WORK_DATE, DUE_DATE, STATUS) "
            f"VALUES ('{wk_no}', '{parent}', {work_qty}, '{MGMT_EMP}', "
            f"'{current_dt.strftime('%Y-%m-%d %H:%M:%S')}', '{due_wk}', '{wk_status}');"
        )

        if wk_status == 'DONE':
            # [1번] 원자재 FIFO 소진 → 실제 투입 원가 합산
            total_material_cost = 0
            for child_cd, req in children:
                total_req = work_qty * req
                log_stock(child_cd, 'OUT', total_req, wk_no, current_dt)
                total_material_cost += fifo_cost(child_cd, total_req)

            # [1번] 완제품 1개당 실제 제조원가 = 투입 원자재 총원가 / 생산수량
            # good_qty > 0 보장 (bad_qty가 work_qty 초과하지 않도록 이미 처리됨)
            actual_unit_cost = int(total_material_cost / work_qty) if work_qty > 0 else BASE_PRICES[parent]

            add_sql(
                f"INSERT INTO tb_work_perf "
                f"(WORK_NO, GOOD_QTY, BAD_QTY, PERF_DATE, EMP_ID) "
                f"VALUES ('{wk_no}', {good_qty}, {bad_qty}, "
                f"'{current_dt.strftime('%Y-%m-%d %H:%M:%S')}', '{MGMT_EMP}');"
            )
            log_stock(parent, 'IN', good_qty, wk_no, current_dt)
            # [1번] 완제품 입고 단가 = 실제 제조원가 (BASE_PRICES 고정값 제거)
            fifo_in(parent, good_qty, actual_unit_cost)

            # [3번] 생산 완료 시계열 원가 기록 — 완제품도 _raw_price_ts에 추가
            _raw_price_ts.setdefault(parent, []).append((current_dt, actual_unit_cost))

            # [3번] 생산 실적 직접 기록
            _production_list.append({"GOOD_QTY": good_qty, "BAD_QTY": bad_qty, "itemCd": parent})

        work_counter += 1

    # ── 판매 수주 ────────────────────────────────────────────
    days_passed       = (current_dt - START_DATE).days
    growth_multiplier = 1 + (days_passed / 730)
    sell_prob         = 0.3 * growth_multiplier

    if random.random() < sell_prob:
        customer = (random.choice(list(HIGH_CANCEL_VENDORS))
                    if random.random() < 0.3 else random.choice(VENDORS_OUT))
        so_no    = f"SO-{current_dt.strftime('%Y%m%d')}-{order_counter:03d}"
        item_cd  = random.choices(SELL_ITEMS, weights=[70, 30])[0]
        sell_qty = random.randint(1, 5)

        cancel_rate       = get_cancel_rate(customer, current_dt)
        so_emp_id, price  = get_emp_and_sell_price(item_cd, phase)
        supply_amt        = sell_qty * price
        vat_amt           = int(supply_amt * 0.1)
        amt               = supply_amt + vat_amt
        due_so            = (current_dt + timedelta(days=14)).strftime('%Y-%m-%d')

        rand = random.random()
        if rand < cancel_rate:
            so_status = 'CANCEL'
        elif rand < cancel_rate + 0.03:
            so_status = 'WAIT'
            stuck_orders.append((current_dt, so_no, item_cd))
        elif rand < cancel_rate + 0.05:
            so_status = 'PROG'
            stuck_orders.append((current_dt, so_no, item_cd))
        else:
            so_status = 'DONE'

        add_sql(
            f"INSERT INTO tb_order "
            f"(ORDER_NO, ORDER_TYPE, ACCT_CD, EMP_ID, ORDER_DATE, DUE_DATE, STATUS) "
            f"VALUES ('{so_no}', 'SELL', '{customer}', '{so_emp_id}', "
            f"'{current_dt.strftime('%Y-%m-%d %H:%M:%S')}', '{due_so}', '{so_status}');"
        )
        add_sql(
            f"INSERT INTO tb_order_detail "
            f"(ORDER_NO, ITEM_CD, QTY, UNIT_PRICE, SUPPLY_AMT, VAT_AMT, AMT) "
            f"VALUES ('{so_no}', '{item_cd}', {sell_qty}, {price}, "
            f"{supply_amt}, {vat_amt}, {amt});"
        )

        if so_status == 'DONE' and current_stock.get(item_cd, 0) >= sell_qty:
            log_stock(item_cd, 'OUT', sell_qty, so_no, current_dt)
            fifo_cost(item_cd, sell_qty)

        # [3번] 판매 데이터 직접 기록 (SQL 파싱 불필요)
        # [test 4번] 키 대소문자 통일 — analyzer.py col_map과 일치
        _sales_list.append({
            "orderdate": int(current_dt.timestamp() * 1000),
            "itemcd":    item_cd,
            "qty":       sell_qty,
            "amt":       amt,
            "status":    so_status,
        })

        order_counter += 1

    current_dt += timedelta(days=1)


# ── SQL 파일 저장 ──────────────────────────────────────────────
with open('dummy_data_scenario_v5.sql', 'w', encoding='utf-8') as f:
    f.write("SET AUTOCOMMIT = 0;\nSTART TRANSACTION;\nSET FOREIGN_KEY_CHECKS = 0;\n\n")
    f.write("DELETE FROM tb_item_log;\nDELETE FROM tb_work_perf;\n"
            "DELETE FROM tb_work_order;\nDELETE FROM tb_order_detail;\nDELETE FROM tb_order;\n\n")
    f.write("-- v5 시나리오 데이터 --\n")
    f.write("\n".join(sql_statements))
    f.write("\n\n-- 현재고 마스터 업데이트 --\n")
    for item, qty in current_stock.items():
        f.write(f"UPDATE tb_item SET STOCK_QTY = {qty} WHERE ITEM_CD = '{item}';\n")
    f.write("\nSET FOREIGN_KEY_CHECKS = 1;\nCOMMIT;\n")

print(f"✅ 생성 완료: dummy_data_scenario_v5.sql ({len(sql_statements)}개 구문)")
print(f"📊 최종 재고: {current_stock}")
print(f"⚠️  품절 이벤트: {len(stockout_events)}건")
print(f"🔴 미결 전표:   {len(stuck_orders)}건")
print(f"📦 판매 기록:   {len(_sales_list)}건 (SQL 파싱 없이 직접 구축)")
print(f"🏭 생산 실적:   {len(_production_list)}건")


# ── 검증 ─────────────────────────────────────────────────────
def verify_with_analyzer():
    import sys, os
    sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
    from rpa_logic.analyzer import analyze_sales_data

    print("\n" + "="*60)
    print("📊 v5 시나리오 검증 (SQL 파싱 없음)")
    print("="*60)

    total  = len(_sales_list)
    done   = sum(1 for s in _sales_list if s['status'] == 'DONE')
    cancel = sum(1 for s in _sales_list if s['status'] == 'CANCEL')
    stuck  = total - done - cancel
    print(f"판매 건수: {total}건 (정상:{done} / 취소:{cancel} / 미결:{stuck})")

    # [1+2번] 월별 시계열 원가 계산 — BOM 4계층 전개 후 월별 완제품 원가 산출
    # _raw_price_ts: {item_cd: [(dt, unit_price), ...]} 루프에서 직접 구축된 데이터
    def price_at(item_cd, dt):
        """item_cd의 dt 시점 직전 실거래 단가 반환 (step-function)."""
        records = sorted(_raw_price_ts.get(item_cd, []), key=lambda x: x[0])
        if not records:
            return BASE_PRICES.get(item_cd, 0)
        matched = records[0][1]
        for rec_dt, rec_price in records:
            if rec_dt <= dt:
                matched = rec_price
            else:
                break
        return matched

    def bom_cost_at(item_cd, dt, _visited=None):
        """
        [test 1번] BOM 딕셔너리 재귀 참조로 완제품 원가 계산.
        하드코딩 제거 — BOM 구조가 바뀌어도 자동 반영.
        """
        if _visited is None:
            _visited = set()
        if item_cd in _visited:
            return 0  # 순환 참조 방어
        _visited.add(item_cd)

        if item_cd not in BOM:
            # 말단 원자재 → 실거래 단가 반환
            return price_at(item_cd, dt)

        total = 0
        for child_cd, req_qty in BOM[item_cd]:
            child_cost = bom_cost_at(child_cd, dt, _visited.copy())
            total += child_cost * req_qty
        return total

    # 월별로 원가 계산 → cost_list 시계열 구성
    from datetime import datetime as _dt
    cost_list_ts = []
    # [test 5번] 월별 → 주별 샘플링으로 세분화 (원가 변동을 더 촘촘히 포착)
    from datetime import timedelta as _td
    cur        = START_DATE
    prev_cost  = None
    while cur <= END_DATE:
        ess_cost_week = bom_cost_at('F-ESS-500', cur)
        # 0.1% 이상 변동 시에만 추가 (노이즈 제거 + 데이터 효율화)
        if prev_cost is None or abs(ess_cost_week - prev_cost) / prev_cost > 0.001:
            cost_list_ts.append({
                'parentCd':  'F-ESS-500',
                'costDate':  cur.strftime('%Y-%m-%d'),
                'unitPrice': int(ess_cost_week),
            })
            prev_cost = ess_cost_week
        cur += _td(weeks=1)  # 주 단위 이동

    print(f"\n[시계열 원가 구성] {len(cost_list_ts)}개 월별 데이터포인트")
    if cost_list_ts:
        first = cost_list_ts[0]
        last  = cost_list_ts[-1]
        print(f"  최초({first['costDate']}): {first['unitPrice']:,}원")
        print(f"  최근({last['costDate']}):  {last['unitPrice']:,}원")
        change = (last['unitPrice'] - first['unitPrice']) / first['unitPrice'] * 100
        print(f"  원가 변동률: {change:+.1f}%")

    # H-RACK-50도 시계열 원가 추가 (SELL_ITEMS에 포함된 다품목 대응)
    cur = START_DATE
    prev_rack = None
    while cur <= END_DATE:
        rack_cost_week = bom_cost_at('H-RACK-50', cur)
        if prev_rack is None or abs(rack_cost_week - prev_rack) / prev_rack > 0.001:
            cost_list_ts.append({
                'parentCd':  'H-RACK-50',
                'costDate':  cur.strftime('%Y-%m-%d'),
                'unitPrice': int(rack_cost_week),
            })
            prev_rack = rack_cost_week
        cur += _td(weeks=1)

    cost_list = cost_list_ts  # analyzer에 시계열로 전달

    # fallback_cost_map: _raw_price_ts의 최신 원가로 모든 품목 커버
    # → H-CELL-100, H-MOD-10 등 cost_list에 없는 불량 품목 원가 오적용 방지
    fallback = {}
    for icd, records in _raw_price_ts.items():
        if records:
            fallback[icd] = sorted(records, key=lambda x: x[0])[-1][1]

    result = analyze_sales_data(
        _sales_list,
        production_list=_production_list,
        cost_list=cost_list,
        fallback_cost_map=fallback
    )
    if 'error' in result:
        print(f"❌ 분석 오류: {result['error']}")
        return

    fs = result['financial_summary']
    print(f"\n[재무 요약]")
    print(f"  총 매출(VAT제외): {fs['total_revenue']:,}원")
    print(f"  총 원가:          {fs['total_cost']:,}원")
    print(f"  순이익률:         {fs['net_margin_rate']}%")
    print(f"  총 수주건수:      {fs['total_orders']}건")

    print(f"\n[Phase별 이익률]")
    monthly   = result.get('monthly_performance', [])
    p1_months = [m for m in monthly if m['month'] <  PHASE2_START.strftime('%Y-%m')]
    p3_months = [m for m in monthly if m['month'] >= PHASE3_START.strftime('%Y-%m')]
    p4_months = [m for m in monthly if m['month'] >= PHASE4_START.strftime('%Y-%m')]
    
    avg_p1 = avg_p3 = None
    if p1_months:
        avg_p1 = sum(m['margin_rate'] for m in p1_months) / len(p1_months)
        print(f"  Phase1 안정기: {avg_p1:.2f}%")
    if p3_months:
        avg_p3 = sum(m['margin_rate'] for m in p3_months) / len(p3_months)
        print(f"  Phase3 위기기 (25년 1~3Q): {avg_p3:.2f}%")
    if p4_months:
        avg_p4 = sum(m['margin_rate'] for m in p4_months) / len(p4_months)
        print(f"  Phase4 회복기 (25년 4Q~): {avg_p4:.2f}%")

    if avg_p3 is not None and avg_p4 is not None:
        diff = avg_p4 - avg_p3
        status = "✅ 회복 추세 생성 성공" if diff > 2 else "⚠️  회복폭 미흡"
        print(f"  반등폭: {diff:.2f}%p → {status}")

    ca = result.get('cancel_analysis', {})
    print(f"\n[취소·미결 분석]")
    print(f"  전체:{ca.get('total_orders')}건 / 취소:{ca.get('cancel_orders')}건 "
          f"/ 취소율:{ca.get('cancel_rate')}%")
    if ca.get('cancel_orders', 0) > 0:
        print(f"  취소 손실: {ca.get('cancel_amount',0):,}원")
    print(f"  미결(WAIT/PROG): {stuck}건")

    qm = result.get('quality_metrics', {})
    if qm:
        print(f"\n[품질 분석]")
        print(f"  양품:{qm.get('total_good',0):,} / 불량:{qm.get('total_bad',0):,} "
              f"/ 수율:{qm.get('yield_rate',0)}%")
        print(f"  불량 기회비용: {result.get('loss_cost',0):,}원")

    print(f"\n[운영 리스크]")
    print(f"  품절 이벤트: {len(stockout_events)}건")
    print(f"  미결 전표:   {len(stuck_orders)}건")

    pred = result.get('prediction', {})
    print(f"\n[AI 예측]")
    print(f"  {pred.get('message','')}")
    print(f"  예상 매출:   {pred.get('predicted_revenue',0):,}원")
    print(f"  예상 이익률: {pred.get('margin_rate',0)}%")


if __name__ == "__main__":
    verify_with_analyzer()
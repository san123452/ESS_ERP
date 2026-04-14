import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from datetime import timedelta


# ── 원가 관련 헬퍼 ────────────────────────────────────────────

def _build_cost_map(cost_list):
    """
    cost_list → 품목코드:원가 딕셔너리 구성
    [1] costDate 컬럼 있음  → 시계열 모드 (_build_timeseries_cost_map)
    [2] reqQty 컬럼 있음    → BOM 전개형 (parentCd별 line_cost 합산)
    [3] unitPrice만 있음    → 단가 직접형 (itemCd별 평균)
    [4] 빈/None             → {} 반환
    """
    if not cost_list:
        return {}

    cost_df = pd.DataFrame(cost_list)
    cost_df.columns = [c.lower() for c in cost_df.columns]

    # [1] 시계열 모드
    date_col = next((c for c in cost_df.columns if c.replace('_','') == 'costdate'), None)
    if date_col:
        return _build_timeseries_cost_map(cost_df, date_col)

    item_col   = next((c for c in cost_df.columns if c.replace('_','') == 'itemcd'),    None)
    price_col  = next((c for c in cost_df.columns if c.replace('_','') == 'unitprice'), None)
    req_col    = next((c for c in cost_df.columns if c.replace('_','') in ('reqqty', 'qty')), None)
    parent_col = next((c for c in cost_df.columns
                       if c.replace('_','') in ('parentcd','parentitem')), None)

    if not item_col or not price_col:
        print("[WARN] cost_list에 itemCd/unitPrice 컬럼 없음. 기본값 사용.")
        return {}

    # [수정] req_col이 없더라도 parent_col이 있으면 BOM으로 간주하여 합산 처리
    if req_col or parent_col:
        cost_df['line_cost'] = (pd.to_numeric(cost_df[price_col], errors='coerce') *
                                pd.to_numeric(cost_df[req_col] if req_col else 1, errors='coerce').fillna(1))
        if parent_col:
            cost_map = cost_df.groupby(parent_col)['line_cost'].sum().to_dict()
        elif len(cost_df[item_col].unique()) == 1:
            cost_map = {'__default__': cost_df['line_cost'].sum()}
        else:
            cost_map = cost_df.groupby(item_col)['line_cost'].sum().to_dict()
            print("[INFO] parentCd 없음 → itemCd(BOM) 기준 원가 합산.")
    else:
        cost_map = cost_df.groupby(item_col)[price_col].mean().to_dict()

    print(f"[원가 맵 구성] {cost_map}")
    return cost_map


def _build_timeseries_cost_map(cost_df, date_col):
    """
    시계열 원가 맵 구성.

    Spring에서 보내는 두 가지 형태를 모두 지원:
    [A] BOM 부품 형태 (parentCd + itemCd + reqQty + unitPrice + costDate)
        → parentCd 기준으로 날짜별 line_cost(unitPrice × reqQty) 합산
        → 완제품 1개당 실제 제조원가를 날짜별로 계산
    [B] 완제품 직접 형태 (parentCd or itemCd + unitPrice + costDate, reqQty 없음)
        → unitPrice를 완제품 원가로 직접 사용
    """
    price_col  = next((c for c in cost_df.columns if c.replace('_','') == 'unitprice'), None)
    req_col    = next((c for c in cost_df.columns if c.replace('_','') in ('reqqty', 'qty')), None)
    parent_col = next((c for c in cost_df.columns
                       if c.replace('_','') in ('parentcd','parentitem')), None)
    item_col   = next((c for c in cost_df.columns if c.replace('_','') in ('itemcd', 'childitemcd')), None)

    # STS 대응: parentcd가 없고 itemcd와 childitemcd가 같이 있다면 itemcd를 부모로 간주
    if not parent_col and 'itemcd' in cost_df.columns and 'childitemcd' in cost_df.columns:
        parent_col = 'itemcd'
        item_col = 'childitemcd'

    if not price_col:
        print("[WARN] 시계열 cost_list에 unitPrice 컬럼 없음.")
        return {}

    cost_df[date_col]  = pd.to_datetime(cost_df[date_col], errors='coerce').astype('datetime64[ns]')
    cost_df[price_col] = pd.to_numeric(cost_df[price_col], errors='coerce')
    cost_df = cost_df.dropna(subset=[date_col, price_col]).sort_values(date_col)

    # [수정] 개별 라인 원가 계산 (수량 반영)
    if req_col:
        cost_df['line_cost'] = cost_df[price_col] * pd.to_numeric(cost_df[req_col], errors='coerce').fillna(1)
    else:
        cost_df['line_cost'] = cost_df[price_col]

    ts_map = {}
    key_col = parent_col or item_col
    if not key_col:
        print("[WARN] 시계열 cost_list에 parentCd/itemCd 컬럼 없음.")
        return {}

    # [수정] 로직 통합: parent_col이나 req_col이 있으면 SUM(BOM 합산), 없으면 MEAN(단순 시세 평균)
    for code, grp in cost_df.groupby(key_col):
        if parent_col or req_col:
            # BOM 형태: 날짜별로 모든 부품 원가 합산하여 완제품 1개 원가 산출
            daily = grp.groupby(date_col)['line_cost'].sum().reset_index()
        else:
            # 단순 시세 형태: 날짜별 평균값 사용 (중복 데이터 방어)
            daily = grp.groupby(date_col)['line_cost'].mean().reset_index()
        
        daily.columns = ['cost_date', 'unit_cost']
        ts_map[code] = daily.sort_values('cost_date')
        print(f"[{'BOM' if parent_col or req_col else '시세'}] {code}: "
              f"{len(daily)}개 시점, 최근원가={daily['unit_cost'].iloc[-1]:,.0f}원")

    print(f"[시계열 원가 맵] {len(ts_map)}개 품목, "
          f"총 {sum(len(v) for v in ts_map.values())}개 데이터포인트")
    return {'__timeseries__': ts_map}


def _apply_timeseries_cost(df, cost_map):
    """
    [analyzer 4번] merge_asof 벡터 연산으로 판매일별 원가 매칭.
    루프 없이 전체 DataFrame을 한 번에 처리 → 수만 건도 빠름.
    품목별로 merge_asof 후 concat.
    """
    ts_map   = cost_map['__timeseries__']
    results  = []

    for item_cd, sub_df in df.groupby('item'):
        sub = sub_df.copy().sort_values('date')
        sub['date'] = sub['date'].astype('datetime64[ns]')  # 타입 통일
        if item_cd in ts_map:
            cost_ts = ts_map[item_cd].copy()
            merged  = pd.merge_asof(
                sub,
                cost_ts,
                left_on='date',
                right_on='cost_date',
                direction='backward'   # sale_date 이전 가장 최근 원가
            )
            # 판매일보다 이른 원가 데이터가 없으면 첫 번째 원가로 채움
            if merged['unit_cost'].isna().any():
                first_price = cost_ts['unit_cost'].iloc[0]
                merged['unit_cost'] = merged['unit_cost'].fillna(first_price)
            sub = merged.drop(columns=['cost_date'], errors='ignore')
        else:
            # 시계열에 없는 품목 → cost_map 내 다른 키 또는 None (이후 fallback 처리)
            sub['unit_cost'] = None
        results.append(sub)

    return pd.concat(results).sort_values('date')


def _get_unit_cost(item_cd, cost_map, fallback_map=None):
    """
    단일값 모드 원가 조회.
    cost_map → fallback_map(외부 주입) → None 순으로 탐색.
    [analyzer 2번] _DEFAULT_COST 하드코딩 제거 — fallback_map으로 외부 주입 가능.
    """
    if item_cd in cost_map:          return cost_map[item_cd]
    if '__default__' in cost_map:    return cost_map['__default__']
    if fallback_map and item_cd in fallback_map:
        return fallback_map[item_cd]
    return None   # None 반환 → 호출 측에서 명시적 처리


# ── 메인 분석 함수 ────────────────────────────────────────────

def analyze_sales_data(sales_list, production_list=None, cost_list=None,
                       vat_included=True, vat_rate=0.1, fallback_cost_map=None):
    """
    ERP 데이터 통합 분석.

    Parameters
    ----------
    sales_list       : 판매 기록 리스트
    production_list  : 생산 실적 리스트 (선택)
    cost_list        : 원가 정보 리스트 (선택) — 단일값 / BOM전개형 / 시계열형 모두 지원
    vat_included     : amT에 VAT가 포함되어 있으면 True(기본값), 공급가액이면 False
                       [analyzer 1번] 면세 품목 / 이미 Net 금액인 경우 False로 전달
    fallback_cost_map: {itemCd: unitPrice} — cost_list에 없는 품목의 외부 기본원가 주입
                       [analyzer 2번] _DEFAULT_COST 하드코딩 대체
    """
    if not sales_list:
        return {"error": "데이터가 없습니다."}

    df = pd.DataFrame(sales_list)

    # [analyzer 5번] 컬럼명 정규화 — rename_map/spring_map 중복 제거, 단일 맵으로 통일
    df.columns = [c.lower() for c in df.columns]
    col_map = {
        'orderdate':  'date',   'order_date': 'date',
        'itemcd':     'item',   'item_cd':    'item',
        'qty':        'qty',
        'amt':        'amount', 'amount':     'amount',
    }
    df = df.rename(columns={k: v for k, v in col_map.items() if k in df.columns})

    # 날짜 변환
    if 'date' in df.columns:
        if pd.api.types.is_numeric_dtype(df['date']):
            df['date'] = pd.to_datetime(df['date'], unit='ms', errors='coerce')
        else:
            if df['date'].astype(str).str.isdigit().all():
                df['date'] = pd.to_datetime(df['date'].astype(float), unit='ms', errors='coerce')
            else:
                df['date'] = pd.to_datetime(df['date'], errors='coerce')
        df = df.dropna(subset=['date'])

    # [수정] 취소 분석을 VAT 차감 전에 수행하여 Spring 원장 금액(VAT 포함)과 일치시킴
    if 'status' in df.columns:
        df['status'] = df['status'].str.upper().fillna('UNKNOWN')
    else:
        df['status'] = 'DONE'

    cancel_df = df[df['status'] == 'CANCEL'].copy()
    df = df[df['status'] != 'CANCEL'].copy()

    # VAT 차감 (공급가액 변환)
    if vat_included and vat_rate > 0:
        df['amount'] = df['amount'] / (1 + vat_rate)

    # 원가 맵 구성
    cost_map = _build_cost_map(cost_list)

    # [analyzer 4번] 시계열 모드: merge_asof 벡터 연산
    if '__timeseries__' in cost_map:
        df = _apply_timeseries_cost(df, cost_map)
        # merge_asof 후 unit_cost가 None인 행 → fallback_cost_map 또는 경고
        if df['unit_cost'].isna().any():
            missing_items = df[df['unit_cost'].isna()]['item'].unique()
            for mi in missing_items:
                fb = fallback_cost_map.get(mi) if fallback_cost_map else None
                if fb:
                    df.loc[df['item'] == mi, 'unit_cost'] = fb
                else:
                    print(f"[WARN] '{mi}' 원가 없음 — 해당 행 원가 0 처리. "
                          f"fallback_cost_map으로 원가를 주입하세요.")
                    df.loc[df['item'] == mi, 'unit_cost'] = 0
        print("[시계열 원가 적용] 판매일별 원가 매칭 완료 (merge_asof)")
    else:
        # [analyzer 2번] 단일값 모드 — fallback_cost_map으로 하드코딩 제거
        def resolve_cost(item_cd):
            uc = _get_unit_cost(item_cd, cost_map, fallback_cost_map)
            if uc is None:
                print(f"[WARN] '{item_cd}' 원가 없음 — 0 처리. fallback_cost_map을 전달하세요.")
                return 0
            return uc
        df['unit_cost'] = df['item'].apply(resolve_cost)

    df['cost'] = df['qty'] * df['unit_cost']

    # [중복 제거] 위에서 처리됨
    df['profit'] = df['amount'] - df['cost']
    df = df.sort_values('date')

    results = {}

    total_all    = len(df) + len(cancel_df)
    cancel_count = len(cancel_df)
    results['cancel_analysis'] = {
        "total_orders":  total_all,
        "done_orders":   len(df),
        "cancel_orders": cancel_count,
        "cancel_rate":   round(cancel_count / total_all * 100, 2) if total_all > 0 else 0,
        "cancel_amount": round(cancel_df['amount'].sum()),
    }

    try:
        # [분석 1] 월별 손익
        monthly_grp = df.groupby(df['date'].dt.strftime('%Y-%m')).agg(
            revenue=('amount', 'sum'), cost=('cost', 'sum'),
            profit=('profit', 'sum'), order_count=('amount', 'count')
        )
        monthly_chart = []
        for month, row in monthly_grp.iterrows():
            margin = round((row['profit'] / row['revenue']) * 100, 2) if row['revenue'] > 0 else 0
            monthly_chart.append({
                "month": month, "revenue": round(row['revenue']),
                "cost": round(row['cost']), "profit": round(row['profit']),
                "margin_rate": margin, "order_count": int(row['order_count'])
            })
        results['monthly_performance'] = monthly_chart

        # [분석 2] 분기별 실적
        df['quarter'] = df['date'].dt.to_period('Q').astype(str)
        quarterly_grp = df.groupby('quarter').agg(
            revenue=('amount', 'sum'), cost=('cost', 'sum'),
            profit=('profit', 'sum'), order_count=('amount', 'count')
        ).reset_index()
        results['quarterly_chart'] = []
        for _, row in quarterly_grp.iterrows():
            margin = round((row['profit'] / row['revenue']) * 100, 2) if row['revenue'] > 0 else 0
            results['quarterly_chart'].append({
                "quarter": row['quarter'],
                "label": f"{row['quarter'][:4]}년 {row['quarter'][-1]}분기",
                "revenue": round(row['revenue']), "cost": round(row['cost']),
                "profit": round(row['profit']), "margin_rate": margin,
                "order_count": int(row['order_count'])
            })

        # [분석 3] 재무 요약
        total_rev    = df['amount'].sum()
        total_cost   = df['cost'].sum()
        total_profit = total_rev - total_cost
        total_orders = len(df)
        results['financial_summary'] = {
            "total_revenue":   int(round(total_rev)),
            "total_cost":      int(round(total_cost)),
            "gross_profit":    int(round(total_profit)),
            "net_margin_rate": float(round((total_profit / total_rev) * 100, 2)) if total_rev > 0 else 0.0,
            "total_orders":    total_orders,
            "avg_order_value": round(df['amount'].mean()) if total_orders > 0 else 0
        }
        results['total_revenue'] = round(total_rev)
        results['total_count']   = total_orders

        # [분석 4] 품질/생산 수율
        if production_list:
            pdf = pd.DataFrame(production_list)
            col_rename = {}
            for col in pdf.columns:
                cl = col.lower().replace('_', '')
                if cl == 'goodqty':                          col_rename[col] = 'goodQty'
                elif cl in ('badqty','defectqty','ngqty'):   col_rename[col] = 'badQty'
                elif cl == 'itemcd':                         col_rename[col] = 'itemCd'
            pdf = pdf.rename(columns=col_rename)

            total_good = int(pdf['goodQty'].sum()) if 'goodQty' in pdf.columns else 0
            total_bad  = int(pdf['badQty'].sum())  if 'badQty'  in pdf.columns else 0
            yield_rate = round(total_good / (total_good + total_bad) * 100, 2) if (total_good + total_bad) > 0 else 0
            results['quality_metrics'] = {
                "total_good": total_good, "total_bad": total_bad, "yield_rate": yield_rate
            }

            # [analyzer 3번] loss_cost — itemCd 없을 때 최솟값 방어
            if 'itemCd' in pdf.columns and 'badQty' in pdf.columns:
                def bad_unit_cost(item_cd):
                    """불량 품목의 원가 조회 — 시계열/단일값/fallback 순으로 탐색"""
                    if '__timeseries__' in cost_map:
                        ts = cost_map['__timeseries__'].get(item_cd)
                        if ts is not None and len(ts) > 0:
                            return float(ts['unit_cost'].iloc[-1])
                    # 시계열에 없으면 단일값 모드로 fallback
                    uc = _get_unit_cost(item_cd, cost_map, fallback_cost_map)
                    if uc is not None:
                        return uc
                    # 최종 fallback: fallback_cost_map에도 없으면 판매 평균 원가 사용
                    avg = float(df['unit_cost'].mean()) if len(df) > 0 else 0
                    print(f"[WARN] 불량품목 '{item_cd}' 원가 없음 — 판매평균원가({avg:,.0f}원) 사용")
                    return avg

                pdf['unit_cost_bad'] = pdf['itemCd'].apply(bad_unit_cost)
                loss_cost = round((pdf['badQty'] * pdf['unit_cost_bad']).sum())
            else:
                # [analyzer 3번] itemCd 없으면 판매 품목 평균 원가 사용 (완제품 단가 오적용 방지)
                avg_unit_cost = float(df['unit_cost'].mean()) if len(df) > 0 else 0
                loss_cost = round(total_bad * avg_unit_cost)
                if total_bad > 0:
                    print(f"[WARN] production_list에 itemCd 없음 — "
                          f"판매 평균 원가({avg_unit_cost:,.0f}원)로 loss_cost 계산.")
            results['loss_cost'] = loss_cost

        results['production_analysis'] = {
            "total_qty": int(df['qty'].sum()),
            "item_breakdown": df.groupby('item')['qty'].sum().astype(int).to_dict()
        }

        # [AI 예측] 60일
        daily_series  = df.groupby('date')['amount'].sum().asfreq('D', fill_value=0)
        forecast_days = 60
        avg_margin    = (total_profit / total_rev) if total_rev > 0 else 0

        non_zero_days = (daily_series > 0).sum()
        if non_zero_days < 2 or total_rev == 0:
            results['prediction'] = {"message": "데이터 부족 또는 매출 데이터 없음으로 예측 불가"}
            return results

        # 최근 6개월 트렌드 블렌딩 (전체 70% + 최근 30%)
        recent_df = df[df['date'] >= df['date'].max() - pd.DateOffset(months=6)]
        if len(recent_df) > 0 and recent_df['amount'].sum() > 0:
            recent_margin  = recent_df['profit'].sum() / recent_df['amount'].sum()
            blended_margin = avg_margin * 0.7 + recent_margin * 0.3
        else:
            blended_margin = avg_margin

        predicted_revenue = 0
        predicted_profit  = 0
        model_name        = ""

        if non_zero_days >= 14:
            try:
                model = ExponentialSmoothing(
                    daily_series, trend="add", seasonal="add", seasonal_periods=7
                ).fit()
                predictions       = model.forecast(forecast_days)
                predicted_revenue = round(sum(max(0, p) for p in predictions))
                predicted_profit  = round(predicted_revenue * blended_margin)
                model_name        = "Holt-Winters (계절성+추세)"
            except Exception as e:
                print(f"[Warning] 시계열 분석 실패({e}), 선형 회귀 전환.")
                predicted_revenue, model_name = _predict_linear_fallback(daily_series, forecast_days)
                predicted_profit = round(predicted_revenue * blended_margin)
        else:
            predicted_revenue, model_name = _predict_linear_fallback(daily_series, forecast_days)
            predicted_profit = round(predicted_revenue * blended_margin)

        results['prediction'] = {
            "predicted_revenue": predicted_revenue,
            "predicted_profit":  predicted_profit,
            "predicted_cost":    predicted_revenue - predicted_profit,
            "margin_rate":       round(blended_margin * 100, 2),
            "message":           f"[{model_name}] 모델로 분석한 향후 {forecast_days}일 예상 매출입니다."
        }

        # [AI 예측 2] 12개월 장기
        # [수정] 원가율도 함께 집계하여 시계열 생성
        monthly_df = df.resample('ME', on='date').agg({'amount': 'sum', 'cost': 'sum'})
        
        if len(monthly_df) >= 12:
            try:
                # [버그 수정] 데이터가 24개월 미만이면 seasonal="add" 사용 시 statsmodels 에러 발생 가능
                use_seasonal = "add" if len(monthly_df) >= 24 else None
                
                # 1. 매출 예측 모델
                rev_model = ExponentialSmoothing(
                    monthly_df['amount'], trend="add", seasonal=use_seasonal, seasonal_periods=12 if use_seasonal else None
                ).fit()
                f_rev = rev_model.forecast(12)

                # 2. 원가율 예측 모델 (Dynamic Cost Ratio)
                # 매출이 없는 달의 원가율 오류 방지 및 결측치 처리
                avg_cr = total_cost / total_rev if total_rev > 0 else 0.8
                monthly_df['cost_ratio'] = (monthly_df['cost'] / monthly_df['amount']).replace([np.inf, -np.inf], np.nan).fillna(avg_cr)
                
                # [수정] damped_trend 매개변수 확인 및 적용
                cr_model = ExponentialSmoothing(monthly_df['cost_ratio'], trend="add", damped_trend=True).fit()
                f_cr = cr_model.forecast(12)

                results['long_term_forecast'] = []
                for i in range(12):
                    rev    = round(max(0, f_rev.iloc[i]))
                    # [수정] 원가율 2.0(적자 100%)까지 허용하여 위기 시나리오 반영
                    pred_cr = max(0.1, min(2.0, f_cr.iloc[i]))
                    cost   = round(rev * pred_cr)
                    prof   = rev - cost
                    margin = round((prof / rev) * 100, 2) if rev > 0 else 0
                    
                    results['long_term_forecast'].append({
                        "month":             (monthly_df.index[-1] + pd.DateOffset(months=i+1)).strftime('%Y-%m'),
                        "predicted_revenue": rev, "predicted_cost": cost,
                        "predicted_profit":  prof, "margin_rate": margin
                    })
            except Exception as e:
                print(f"[Warning] 12개월 예측 실패: {e}")

        return results

    except Exception as e:
        import traceback
        print(f"[ERROR DETAIL]:\n{traceback.format_exc()}")
        return {"error": f"분석 중 오류 발생: {str(e)}"}


def _predict_linear_fallback(series, days):
    try:
        df_temp = series.reset_index()
        df_temp.columns = ['date', 'amount']
        df_temp['date_ordinal'] = df_temp['date'].map(pd.Timestamp.toordinal)
        model = LinearRegression().fit(df_temp[['date_ordinal']], df_temp['amount'])
        last_date       = df_temp['date'].max()
        future_ordinals = np.array([
            (last_date + timedelta(days=i)).toordinal() for i in range(1, days+1)
        ]).reshape(-1, 1)
        return round(sum(max(0, p) for p in model.predict(future_ordinals))), "Linear Regression (단순 추세)"
    except:
        return 0, "Error"
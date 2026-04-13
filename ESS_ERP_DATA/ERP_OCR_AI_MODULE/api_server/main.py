from fastapi import FastAPI, UploadFile, File, Body
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware # 추가
from pydantic import BaseModel, Field # 데이터 검증용
from typing import List, Any   # Any 추가
import uvicorn
import sys
import os
import uuid

# 프로젝트 루트 경로를 인식하게 함 (ocr_engine 등을 불러오기 위함)
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from ocr_engine.processor import extract_text
from ocr_engine.formatter import format_to_dataframe

from rpa_logic.analyzer import analyze_sales_data
from rpa_logic.excel_maker import generate_excel_report

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # 모든 도메인에서의 접속 허용 (테스트용)
    allow_methods=["*"],
    allow_headers=["*"],
)

# [Step 3] 분석용 데이터 모델 정의 (Java에서 보낼 JSON 구조)
class SalesRecord(BaseModel):
    orderDate: Any = Field(..., description="주문 날짜 (문자열 또는 타임스탬프)")
    itemCd: str = Field(..., description="품목 코드")
    qtY: int = Field(..., description="판매 수량")
    amT: int = Field(..., description="판매 금액")

# [Step 4] DB 저장용 데이터 모델
class OrderItem(BaseModel):
    item_name: str
    quantity: int
    unit_price: int
    total_price: int

class OrderSaveRequest(BaseModel):
    vendor: str
    items: List[OrderItem]

@app.get("/")
def read_root():
    return {"message": "ERP AI Module is Running!"}

@app.post("/ocr")
async def perform_ocr(file: UploadFile = File(...)):
    # 1. 전달받은 이미지를 임시 저장
    content = await file.read()
    
    # [수정] 파일명 중복 방지를 위해 UUID 사용하되, 원본 확장자 유지 (PDF 인식을 위해)
    file_ext = os.path.splitext(file.filename)[1] if file.filename else ".png"
    temp_filename = f"temp_{uuid.uuid4()}{file_ext}"
    
    with open(temp_filename, "wb") as f:
        f.write(content)

    try:
        # 2. OCR 실행 (processor.py 호출)
        raw_text = extract_text(temp_filename)

        # 3. Pandas 정제 (formatter.py 호출)
        df = format_to_dataframe(raw_text)
        
    finally:
        # 4. 임시 파일 삭제 (청소) - 에러 발생 여부와 상관없이 실행
        if os.path.exists(temp_filename):
            os.remove(temp_filename)
    
    # [서버 로그] 분석된 데이터 터미널에 출력 (디버깅용)
    print(f"\n[🔍 Server Log] 분석 결과 ({len(df)}건 감지):")
    print(df[['item_name', 'quantity', 'unit_price']].to_string(index=False))

    return {
        "status": "success",
        "raw_data": raw_text,
        "items": df.to_dict(orient='records') # JSON 형식으로 변환
    }

# [Step 3] 수익 분석 API 엔드포인트
@app.post("/analyze")
async def analyze_sales(payload: Any = Body(...)):
    """
    Spring에서 보낸 판매 기록 리스트(List) 또는 래핑된 객체(Dict)를 분석하여 반환합니다.
    - List 형태: [{"orderDate": ..., "itemCd": ..., ...}, ...]
    - Dict 래핑 형태: {"sales": [...], "production": [...], "cost": [...]}
    """
    if isinstance(payload, list):
        # 기존 방식: 리스트 직접 전달
        data_list = payload
        production_list = None
        cost_list = None
    elif isinstance(payload, dict):
        # 신규 방식: dict로 래핑하여 전달
        # "sales" 또는 "salesList" 키 둘 다 대응
        data_list = payload.get("sales_list",          # ✅ 실제 키
                    payload.get("sales", 
                    payload.get("salesList", [])))
    
        production_list = payload.get("production_list",  # ✅ 실제 키
                          payload.get("production",
                          payload.get("productionList", None)))
    
        cost_list = payload.get("bom_cost",
                    payload.get("cost_list",
                    payload.get("cost",
                    payload.get("costList", None))))
        print(f"[DEBUG cost_list]: {cost_list}")  # ✅ 이 줄 추가
    else:
        return {"error": "지원하지 않는 데이터 형식입니다. List 또는 Dict로 전송해주세요."}

    # ✅ 여기 추가
    print(f"[PAYLOAD TYPE]: {type(payload)}")
    print(f"[PAYLOAD KEYS]: {list(payload.keys()) if isinstance(payload, dict) else 'LIST'}")
    print(f"[DATA_LIST 길이]: {len(data_list)}")
    print(f"[DATA_LIST 첫번째 항목]: {data_list[0] if data_list else '없음'}")

    result = analyze_sales_data(data_list, production_list, cost_list)

    # ✅ 여기 추가
    print(f"[RESULT KEYS]: {list(result.keys())}")
    print(f"[RESULT financial_summary]: {result.get('financial_summary')}")

    return result

# [Step 5] 엑셀 보고서 생성 API
@app.post("/generate-excel")
async def download_excel_report(analysis_data: dict):
    """
    프론트엔드에서 받은 분석 데이터를 엑셀 파일로 변환하여 반환합니다.
    """
    output = generate_excel_report(analysis_data)
    
    headers = {
        'Content-Disposition': 'attachment; filename="ERP_Sales_Report.xlsx"'
    }
    return StreamingResponse(output, 
                             media_type='application/vnd.openpyxlformats-officedocument.spreadsheetml.sheet', 
                             headers=headers)

# [Step 4] 전표 저장 API (DB 연결 시뮬레이션)
@app.post("/order/save")
async def save_order(order: OrderSaveRequest):
    # 실제 DB 연결이 있다면 여기서 INSERT 쿼리를 실행합니다.
    # 현재는 SQL을 생성하여 로그로 보여줍니다.
    
    print(f"\n[💾 DB Save Request] 거래처: {order.vendor}")
    save_count = 0
    for item in order.items:
        sql = f"INSERT INTO tb_order_detail (ITEM_NM, QTY, PRICE) VALUES ('{item.item_name}', {item.quantity}, {item.unit_price});"
        print(f"   >> 실행 SQL: {sql}")
        save_count += 1
        
    return {
        "status": "success",
        "message": f"총 {save_count}건의 품목이 저장되었습니다.",
        "vendor": order.vendor
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
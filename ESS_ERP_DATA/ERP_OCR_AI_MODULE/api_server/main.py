from fastapi import FastAPI, UploadFile, File, Body, HTTPException
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, ConfigDict # ConfigDict 추가
from typing import List, Any, Optional
import logging
import uvicorn
import sys
import os
import uuid

# 프로젝트 루트 경로를 인식하게 함 (ocr_engine 등을 불러오기 위함)
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from ocr_engine.processor import extract_text
from ocr_engine.formatter import format_to_dataframe

from rpa_logic.analyzer import analyze_sales_data
from rpa_logic.excel_maker import build_macro_enabled_report, MissingMacroTemplateError

# 로깅 설정
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger("ERP_AI_MODULE")

app = FastAPI()

# CORS 설정 (환경 변수에 따라 제한 가능하도록 구성)
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_methods=["*"],
    allow_headers=["*"],
)

# [Step 3] 분석용 데이터 모델 정의 (Java에서 보낼 JSON 구조)
class SalesRecord(BaseModel):
    model_config = ConfigDict(populate_by_name=True) # 별칭과 실제 필드명 모두 허용
    orderDate: Any = Field(..., description="주문 날짜 (문자열 또는 타임스탬프)")
    itemCd: str = Field(..., description="품목 코드")
    qty: int = Field(..., alias="qtY", description="판매 수량")
    amt: int = Field(..., alias="amT", description="판매 금액")
    status: Optional[str] = "DONE"

class AnalysisRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)
    # Spring에서 보낼 수 있는 다양한 키 이름을 별칭으로 대응
    sales_list: List[SalesRecord] = Field(..., alias="salesList")
    production_list: Optional[List[dict]] = Field(None, alias="productionList")
    bom_cost: Optional[List[dict]] = Field(None, alias="bomCost")

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
    
    logger.info(f"OCR 처리 완료: {len(df)}건의 품목 감지")

    return {
        "status": "success",
        "raw_data": raw_text,
        "items": df.to_dict(orient='records') # JSON 형식으로 변환
    }

# [Step 3] 수익 분석 API 엔드포인트
@app.post("/analyze")
async def analyze_sales(request: AnalysisRequest):
    """
    Pydantic 모델을 통해 검증된 데이터를 분석하여 반환합니다.
    """
    data_list = [s.model_dump(by_alias=True) for s in request.sales_list]
    result = analyze_sales_data(data_list, request.production_list, request.bom_cost)
    logger.info(f"분석 요청 처리 완료: {len(data_list)}건 판매 데이터")

    return result

# [Step 5] 엑셀 보고서 생성 API
@app.post("/generate-excel")
async def download_excel_report(analysis_data: dict):
    """
    프론트엔드에서 받은 분석 데이터를 엑셀 파일로 변환하여 반환합니다.
    """
    try:
        artifact = build_macro_enabled_report(analysis_data)
    except MissingMacroTemplateError as exc:
        logger.error("Excel macro template is missing: %s", exc)
        raise HTTPException(status_code=500, detail=str(exc)) from exc

    headers = {
        "Content-Disposition": f'attachment; filename="{artifact.filename}"'
    }
    return StreamingResponse(
        artifact.buffer,
        media_type=artifact.media_type,
        headers=headers,
    )

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

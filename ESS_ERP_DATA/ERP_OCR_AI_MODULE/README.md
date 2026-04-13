# ERP OCR 및 AI 분석 모듈

이 프로젝트는 이미지/PDF 형태의 전표를 OCR로 읽어 데이터를 정제하고, 판매 및 생산 실적을 분석하여 향후 매출을 예측하는 모듈입니다.

## 1. 필수 소프트웨어 설치

이 모듈이 정상 작동하려면 파이썬 패키지 외에 아래의 도구들이 시스템에 설치되어 있어야 합니다.

### 1.1 Tesseract OCR (문자 인식 엔진)
- **Windows**: [Tesseract installer](https://github.com/UB-Mannheim/tesseract/wiki)를 다운로드하여 설치합니다.
- 설치 경로가 `C:\Program Files\Tesseract-OCR\tesseract.exe`가 아닐 경우 `ocr_engine/processor.py` 코드를 수정해야 합니다.

### 1.2 Poppler (PDF 변환 도구)
PDF 파일을 OCR 처리하기 위해 필요합니다.
- **설치 방법**:
    1. Poppler for Windows에서 최신 버전을 다운로드합니다.
    2. 압축을 푼 뒤, 내부의 `Library/bin` 폴더 경로를 확인합니다.
    3. **방법 A (권장)**: 프로젝트 루트에 `external/poppler` 폴더를 만들고 그 안에 `bin` 폴더 내용물을 복사합니다. 코드가 이 경로를 자동으로 탐색합니다.
    4. **방법 B**: 시스템 환경 변수(PATH)에 `bin` 경로를 추가합니다.

## 2. 환경 설정

```bash
# 가상환경 생성
python -m venv venv

# 가상환경 활성화 (Windows)
source venv/Scripts/activate

# 필수 패키지 설치
pip install -r requirements.txt
```

## 3. 실행 방법

### 3.1 API 서버 실행
```bash
python api_server/main.py
```
서버가 실행되면 `http://localhost:8000/docs`에서 API 명세서를 확인할 수 있습니다.

### 3.2 시뮬레이션 및 분석 테스트
```bash
python test_analytics.py
```
이 스크립트는 2년간의 가상 운영 데이터를 생성하여 SQL 파일로 저장하고, 분석 모듈의 정확도를 검증합니다.

## 4. 라이브러리 구성
- **OCR**: pytesseract, OpenCV, pdf2image
- **분석/예측**: pandas, scikit-learn, statsmodels
- **서버**: FastAPI, uvicorn
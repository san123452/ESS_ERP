"""
processor.py
────────────
기존 extract_text()의 개선 버전.

개선 사항:
  - 이미지 업스케일 (가로 1200px 기준)
  - 그레이스케일 변환
  - Otsu 이진화 (글자/배경 자동 분리)
  - 노이즈 제거 (morphologyEx)
  - psm 6 + oem 3 옵션 명시

추가 기능:
  - PDF 파일 지원 (pdf2image 필요)
  - Adaptive Thresholding (그림자/조명 변화에 강함)
"""

import cv2
import numpy as np
import pytesseract
from PIL import Image
import os

# PDF 처리를 위한 라이브러리 (없으면 무시)
try:
    from pdf2image import convert_from_path
    HAS_PDF_LIB = True
except ImportError:
    HAS_PDF_LIB = False

pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

# [추가] Poppler 경로 자동 설정 (external 폴더 활용)
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))  # .../ocr_engine
PROJECT_ROOT = os.path.dirname(CURRENT_DIR)               # .../erp_ocr_ai_module

def _find_poppler_path():
    """external 폴더 내부를 탐색하여 pdfinfo.exe가 있는 실제 bin 경로를 찾습니다."""
    external_dir = os.path.join(PROJECT_ROOT, "external")
    if not os.path.exists(external_dir):
        return None

    # os.walk로 모든 하위 폴더를 뒤져서 pdfinfo.exe가 있는 곳을 찾음
    for root, dirs, files in os.walk(external_dir):
        if "pdfinfo.exe" in files:
            return root
    return None

POPPLER_PATH = _find_poppler_path()

if POPPLER_PATH:
    print(f"[System] Poppler detected at: {POPPLER_PATH}")
else:
    print("[Warning] Poppler binaries not found in 'external' folder.")

def preprocess_image(image_path: str) -> np.ndarray:
    """
    OCR 인식률을 높이기 위한 이미지 전처리.
    PDF, PNG, JPG 등을 모두 지원하며, 적응형 이진화를 적용함.
    Returns: 전처리된 OpenCV 이미지 (grayscale ndarray)
    """
    # 1. 파일 확장자에 따른 로딩 방식 분기
    ext = os.path.splitext(image_path)[1].lower()
    img = None

    if ext == '.pdf':
        if HAS_PDF_LIB:
            # PDF의 첫 페이지만 이미지로 변환 (300 DPI)
            # [수정] poppler_path 명시
            pages = convert_from_path(image_path, dpi=300, poppler_path=POPPLER_PATH)
            if pages:
                img = np.array(pages[0])
        else:
            print("[Warning] pdf2image 라이브러리가 없어 PDF를 처리할 수 없습니다. pip install pdf2image 및 Poppler 설치를 확인하세요.")
            return np.zeros((100, 100), dtype=np.uint8) # 빈 이미지 반환
    
    if img is None:
        # 일반 이미지(PNG, JPG 등) 로딩
        pil_img = Image.open(image_path).convert("RGB")
        img = np.array(pil_img)

    # 2. 업스케일 - 가로 1200px 미만이면 확대
    #    테서렉트는 300 DPI 이상에서 인식률이 크게 올라감
    h, w = img.shape[:2]
    if w < 1200:
        scale = 1200 / w
        img = cv2.resize(img, (int(w * scale), int(h * scale)), interpolation=cv2.INTER_CUBIC)

    # 3. 그레이스케일 변환
    gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)

    # 4. [개선] 적응형 이진화 (Adaptive Thresholding)
    #    단순 Otsu보다 그림자나 조명 변화가 있는 문서에서 글자를 더 잘 따냄
    #    Block Size: 21 (홀수), C: 10 (상수, 노이즈 필터링 강도)
    binary = cv2.adaptiveThreshold(
        gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 21, 10
    )

    # 5. 노이즈 제거
    kernel = np.ones((1, 1), np.uint8)
    cleaned = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)

    return cleaned


def extract_text(image_path: str) -> str:
    """
    기존 extract_text()와 동일한 인터페이스.
    전처리 후 테서렉트 실행.
    """
    try:
        processed = preprocess_image(image_path)

        # psm 6: 균일한 텍스트 블록 → 컬럼 줄 누락 방지
        # oem 3: LSTM 엔진 (기본값, 명시)
        custom_config = r'--oem 3 --psm 6'

        text = pytesseract.image_to_string(
            processed,
            lang='kor+eng',
            config=custom_config
        )
        return text

    except Exception as e:
        return f"Error: {e}"
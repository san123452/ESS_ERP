package com.ess.erp.controller;
import org.springframework.http.HttpHeaders;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import com.ess.erp.service.SalesOrderService;
@Controller
@RequestMapping("/finance")
public class FinanceController {
    @Autowired
    private SalesOrderService salesOrderService;
    @GetMapping("/report")
    public String report() {
        return "finance/report";
    }
    // 1단계: 분석결과를 JSON으로 반환 (차트 표시용)
    @PostMapping("/report/analyze")
    @ResponseBody
    public ResponseEntity<byte[]> analyze() {
        // DB 데이터 수집
        List<Map<String, Object>> sales       = salesOrderService.getSalesData();
        List<Map<String, Object>> purchase    = salesOrderService.getPurchaseData();
        List<Map<String, Object>> badLoss     = salesOrderService.getBadLossData();
        List<Map<String, Object>> production  = salesOrderService.getProductionData();
        List<Map<String, Object>> itemMaster  = salesOrderService.getItemMasterData();
        List<Map<String, Object>> bomCostList = salesOrderService.getBomCostData();
        System.out.println("BOM 원가 데이터 개수: " + bomCostList.size());
        System.out.println("BOM 원가 샘플: " + (bomCostList.isEmpty() ? "없음" : bomCostList.get(0)));
        try {
            RestTemplate restTemplate = new RestTemplate();
            // ✅ 세 가지 데이터를 하나의 Map으로 묶어서 전송
            Map<String, Object> payload = new HashMap<>();
            payload.put("sales_list",      sales);
            payload.put("bom_cost", bomCostList);   // 매입 → 원가 계산용
            payload.put("production_list", badLoss);    // 생산실적/불량 → 양품률·손실 계산용
            payload.put("production_data", production); // 생산실적 전체 → 양품률 계산용
            payload.put("item_list",       itemMaster); // 품목 마스터 → 단가 계산용
           
            
            // 1단계: Python 분석 요청
            String pythonUrl = "http://192.168.0.221:8000/analyze";
            Map<String, Object> result = restTemplate.postForObject(pythonUrl, payload, Map.class);
            System.out.println("Python 분석 결과: " + result);
            
            // 2단계: 엑셀 생성 요청
            String excelUrl = "http://192.168.0.221:8000/generate-excel";
            byte[] excelBytes = restTemplate.postForObject(excelUrl, result, byte[].class);
            System.out.println("엑셀 생성 결과: " + excelBytes.length + " bytes");
            
            // 3단계: 브라우저로 엑셀 다운로드
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
            headers.add("Content-Disposition", "attachment; filename=report.xlsx");
            return new ResponseEntity<>(excelBytes, headers, HttpStatus.OK);
            
        } catch (Exception e) {
            System.err.println("Python 서버 오류: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
       
    @PostMapping("/report/download")
    public String download() {
        return "finance/report";
    }
}
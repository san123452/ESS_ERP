package com.ess.erp.logis;

import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ess.erp.domain.ClientDTO;
import com.ess.erp.mapper.ClientMapper;

@Service
public class ClientService {

    private final ClientMapper clientMapper;

    // 생성자 주입
    public ClientService(ClientMapper clientMapper) {
        this.clientMapper = clientMapper;
    }

    @Transactional
    public void registerClient(ClientDTO clientDTO) {
    	// 여기에 추가 (콘솔창에 AC001 같은 값이 찍히는지 확인)
        System.out.println("등록하려는 거래처 코드: " + clientDTO.getAcctCd());
        clientMapper.insertClient(clientDTO);
    }

    public List<ClientDTO> getClientList() {
        return clientMapper.selectClientList();
    }
    
    public List<ClientDTO> getClientListByType(String type) {
        return clientMapper.getClientListByType(type);
    }

    @Transactional
    public void removeClient(String acctCd) {
        clientMapper.deleteClient(acctCd);
    }
}
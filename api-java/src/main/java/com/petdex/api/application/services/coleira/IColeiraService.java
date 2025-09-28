package com.petdex.api.application.services.coleira;

import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.coleira.ColeiraReqDTO;
import com.petdex.api.domain.contracts.dto.coleira.ColeiraResDTO;
import org.springframework.data.domain.Page;

public interface IColeiraService {

    ColeiraResDTO findById(String id);
    Page<ColeiraResDTO> findAll(PageDTO pageDTO);
    ColeiraResDTO findByAnimal(String id);
    ColeiraResDTO create(ColeiraReqDTO coleiraReqDTO);
    ColeiraResDTO update(String id, ColeiraReqDTO coleiraReqDTO);
    void delete(String id);
}

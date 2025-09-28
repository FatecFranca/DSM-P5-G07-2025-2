package com.petdex.api.application.services.especie;

import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.especie.EspecieReqDTO;
import com.petdex.api.domain.contracts.dto.especie.EspecieResDTO;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;


public interface IEspecieService {

    EspecieResDTO findById(String id);
    Page<EspecieResDTO> findAll (PageDTO pageDTO);
    EspecieResDTO create (EspecieReqDTO especieReqDTO);
    EspecieResDTO update (String id, EspecieReqDTO especieReqDTO);
    void delete (String id);
}

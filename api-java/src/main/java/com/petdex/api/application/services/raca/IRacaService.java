package com.petdex.api.application.services.raca;

import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaReqDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaResDTO;
import org.springframework.data.domain.Page;

public interface IRacaService {

    RacaResDTO findById(String id);
    Page<RacaResDTO> findAll (PageDTO pageDTO);
    RacaResDTO create (RacaReqDTO racaReqDTO);
    RacaResDTO update (String id, RacaReqDTO racaReqDTO);
    void delete (String id);
}

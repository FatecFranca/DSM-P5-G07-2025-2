package com.petdex.api.application.services.raca;

import com.petdex.api.domain.collections.Raca;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaReqDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaResDTO;
import org.springframework.data.domain.Page;

import java.util.List;

public interface IRacaService {

    RacaResDTO findById(String id);
    Page<RacaResDTO> findAll (PageDTO pageDTO);
    Page<RacaResDTO> findAllByEspecieId(String especieId, PageDTO pageDTO);
    RacaResDTO create (RacaReqDTO racaReqDTO);
    RacaResDTO update (String id, RacaReqDTO racaReqDTO);
    void delete (String id);

    // Método temporário de debug - REMOVER DEPOIS
    List<Raca> debugGetAllRacas();
}

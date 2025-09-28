package com.petdex.api.application.services.batimento;

import com.petdex.api.domain.contracts.dto.batimento.BatimentoReqDTO;
import com.petdex.api.domain.contracts.dto.batimento.BatimentoResDTO;
import com.petdex.api.domain.contracts.dto.PageDTO;
import org.springframework.data.domain.Page;

public interface IBatimentoService {

     BatimentoResDTO save(BatimentoReqDTO batimentoReq);
     BatimentoResDTO fidById(String batimentoId);
     Page<BatimentoResDTO> findAllByAnimalId(String animalId, PageDTO pageDTO);
     Page<BatimentoResDTO> findAllByColeiraId(String coleiraId, PageDTO pageDTO);

}

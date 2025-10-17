package com.petdex.api.application.services.localizacao;

import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoReqDTO;
import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoResDTO;
import com.petdex.api.domain.contracts.dto.PageDTO;
import org.springframework.data.domain.Page;

import java.util.Optional;

public interface ILocalizacaoService {
    LocalizacaoResDTO save(LocalizacaoReqDTO localizacaoReq);
    LocalizacaoResDTO fidById(String localizacaoId);
    Page<LocalizacaoResDTO> findAllByAnimalId(String animalId, PageDTO pageDTO);
    Page<LocalizacaoResDTO> findAllByColeiraId(String coleiraId, PageDTO pageDTO);

    /**
     * Busca a última localização registrada de um animal
     * @param animalId ID do animal
     * @return Optional contendo a última localização se existir
     */
    Optional<LocalizacaoResDTO> findLastByAnimalId(String animalId);
}

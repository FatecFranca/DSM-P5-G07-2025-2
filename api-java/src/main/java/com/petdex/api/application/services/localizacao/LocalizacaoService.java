package com.petdex.api.application.services.localizacao;

import com.petdex.api.application.services.ValidationService;
import com.petdex.api.domain.collections.Localizacao;
import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoReqDTO;
import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoResDTO;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.infrastructure.mongodb.LocalizacaoRepository;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LocalizacaoService implements ILocalizacaoService {

    @Autowired
    private LocalizacaoRepository localizacaoRepository;

    @Autowired
    private ValidationService validation;

    @Autowired
    private ModelMapper mapper;

    public LocalizacaoResDTO save(LocalizacaoReqDTO localizacaoReq) {
//
//        if (!validation.existAnimal(localizacaoReq.getAnimalId()) || !validation.existColeira(localizacaoReq.getColeiraId())) {
//            return null; // Lançar excessão 404
//        }

        return mapper.map(localizacaoRepository.save(mapper.map(localizacaoReq, Localizacao.class)), LocalizacaoResDTO.class);
    }

    public LocalizacaoResDTO fidById(String localizacaoId) {
        return mapper.map(localizacaoRepository.findById(localizacaoId), LocalizacaoResDTO.class);
    }

    public Page<LocalizacaoResDTO> findAllByAnimalId(String animalId, PageDTO pageDTO) {
        pageDTO.sortByNewest();
        Page<Localizacao> localizacaosPage = localizacaoRepository.findAllByAnimal(animalId, pageDTO.mapPage());

        List<LocalizacaoResDTO> dtoList = localizacaosPage.getContent().stream()
                .map(b -> mapper.map(b, LocalizacaoResDTO.class))
                .toList();

        return new PageImpl<LocalizacaoResDTO>(dtoList, pageDTO.mapPage(), localizacaosPage.getTotalElements());
    }

    public Page<LocalizacaoResDTO> findAllByColeiraId(String coleiraId, PageDTO pageDTO) {
        pageDTO.sortByNewest();
        Page<Localizacao> localizacaosPage = localizacaoRepository.findAllByColeira(coleiraId, pageDTO.mapPage());

        List<LocalizacaoResDTO> dtoList = localizacaosPage.getContent().stream()
                .map(b -> mapper.map(b, LocalizacaoResDTO.class))
                .toList();

        return new PageImpl<LocalizacaoResDTO>(dtoList, pageDTO.mapPage(), localizacaosPage.getTotalElements());
    }


}

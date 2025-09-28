package com.petdex.api.application.services.raca;

import com.petdex.api.domain.collections.Especie;
import com.petdex.api.domain.collections.Raca;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaReqDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaResDTO;
import com.petdex.api.infrastructure.mongodb.EspecieRepository;
import com.petdex.api.infrastructure.mongodb.RacaRepository;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RacaService implements IRacaService{

    @Autowired
    ModelMapper mapper;

    @Autowired
    RacaRepository racaRepository;

    @Autowired
    EspecieRepository especieRepository;

    @Override
    public RacaResDTO findById(String id) {
        return mapper.map(racaRepository.findById(id), RacaResDTO.class);
    }

    @Override
    public Page<RacaResDTO> findAll(PageDTO pageDTO) {

        pageDTO.sortByName();

        Page<Raca> racaPage = racaRepository.findAll(pageDTO.mapPage());
        List<RacaResDTO> dtoList = racaPage.getContent().stream()
                .map(r -> mapper.map(r, RacaResDTO.class))
                .toList();


        return new PageImpl<RacaResDTO>(dtoList, pageDTO.mapPage(), racaPage.getTotalElements());
    }

    @Override
    public RacaResDTO create(RacaReqDTO racaReqDTO) {

        Especie especie = especieRepository.findById(racaReqDTO.getEspecie()).orElseThrow(() -> new RuntimeException("Especie com o ID não encontrada: " + racaReqDTO.getEspecie()));
        return mapper.map(racaRepository.save(mapper.map(racaReqDTO, Raca.class)), RacaResDTO.class);
    }

    @Override
    public RacaResDTO update(String id, RacaReqDTO racaReqDTO) {

        Raca racaUptade = racaRepository.findById(id).orElseThrow(()->new RuntimeException("Não foi possível encontrar uma raça com o ID: "+ id));

        if(racaReqDTO.getNome() != null) racaUptade.setNome(racaReqDTO.getNome());
        if(racaReqDTO.getEspecie()!=null) {
            Especie especie = especieRepository.findById(racaReqDTO.getEspecie()).orElseThrow(() -> new RuntimeException("Especie com o ID não encontrada: " + racaReqDTO.getEspecie()));
            racaUptade.setEspecie(racaReqDTO.getEspecie());
        }

        return mapper.map(racaRepository.save(racaUptade), RacaResDTO.class);
    }

    @Override
    public void delete(String id) {
       Raca racaDelete =  racaRepository.findById(id)
               .orElseThrow(() -> new RuntimeException("Não foi possível encontrar uma raça com o ID: " + id));
       racaRepository.delete(racaDelete);
    }
}

package com.petdex.api.application.services.coleira;

import com.petdex.api.domain.collections.Animal;
import com.petdex.api.domain.collections.Coleira;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.coleira.ColeiraReqDTO;
import com.petdex.api.domain.contracts.dto.coleira.ColeiraResDTO;
import com.petdex.api.infrastructure.mongodb.AnimalRepository;
import com.petdex.api.infrastructure.mongodb.ColeiraRepository;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpServerErrorException;

import java.util.List;

@Service
public class ColeiraService implements IColeiraService {

    @Autowired
    ColeiraRepository coleiraRepository;

    @Autowired
    AnimalRepository animalRepository;

    @Autowired
    ModelMapper mapper;

    @Override
    public ColeiraResDTO findById(String id) {
        return mapper.map(coleiraRepository.findById(id)
                        .orElseThrow(() -> new HttpServerErrorException(HttpStatus.NOT_FOUND, "Não existe coleira com o ID: " + id)),
                ColeiraResDTO.class);
    }

    @Override
    public Page<ColeiraResDTO> findAll(PageDTO pageDTO) {

        Page<Coleira> coleiraPage = coleiraRepository.findAll(pageDTO.mapPage());

        List<ColeiraResDTO> dtoList = coleiraPage.getContent()
                .stream().map(c -> mapper.map(c, ColeiraResDTO.class))
                .toList();


        return new PageImpl<ColeiraResDTO>(dtoList, pageDTO.mapPage(), coleiraPage.getTotalElements());
    }

    @Override
    public ColeiraResDTO findByAnimal(String id) {
        return null;
    }

    @Override
    public ColeiraResDTO create(ColeiraReqDTO coleiraReqDTO) {

        Animal animal = animalRepository.findById(coleiraReqDTO.getAnimal())
                .orElseThrow(() -> new HttpServerErrorException(HttpStatus.NOT_FOUND, "Não existe animal com o ID: " + coleiraReqDTO.getAnimal()));

        return mapper.map(coleiraRepository.save(mapper.map(coleiraReqDTO, Coleira.class)), ColeiraResDTO.class);
    }

    @Override
    public ColeiraResDTO update(String id, ColeiraReqDTO coleiraReqDTO) {
        Coleira coleiraUpdate = coleiraRepository.findById(id).orElseThrow(() ->
                new HttpServerErrorException(HttpStatus.NOT_FOUND, "Não existe coleira com o ID: " + id));

        if (coleiraReqDTO.getDescricao() != null) coleiraUpdate.setDescricao(coleiraReqDTO.getDescricao());
        if (coleiraReqDTO.getAnimal() != null) {
            Animal animal = animalRepository.findById(coleiraReqDTO.getAnimal())
                    .orElseThrow(() -> new HttpServerErrorException(HttpStatus.NOT_FOUND, "Não existe aniaml com o ID: " + coleiraReqDTO.getAnimal()));

            coleiraUpdate.setAnimal(coleiraReqDTO.getAnimal());
        }
        return mapper.map(coleiraRepository.save(coleiraUpdate), ColeiraResDTO.class);
    }

    @Override
    public void delete(String id) {
        Coleira coleiraDelete = coleiraRepository.findById(id).orElseThrow(() ->
                new HttpServerErrorException(HttpStatus.NOT_FOUND, "Não existe coleira com o ID: " + id));

        coleiraRepository.delete(coleiraDelete);
    }
}

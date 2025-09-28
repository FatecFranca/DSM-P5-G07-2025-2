package com.petdex.api.application.services.animal;

import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.animal.AnimalReqDTO;
import com.petdex.api.domain.contracts.dto.animal.AnimalResDTO;
import org.springframework.data.domain.Page;

public interface IAnimalService {
    AnimalResDTO findById(String id);
    Page<AnimalResDTO> findAll(PageDTO pageDTO);
    AnimalResDTO create (AnimalReqDTO animalReqDTO);
    AnimalResDTO update (String id, AnimalReqDTO animalReqDTO);
    void delete (String id);

}

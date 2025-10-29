package com.petdex.api.application.services.animal;

import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.animal.AnimalReqDTO;
import com.petdex.api.domain.contracts.dto.animal.AnimalResDTO;
import org.springframework.data.domain.Page;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Optional;

public interface IAnimalService {
    AnimalResDTO findById(String id);
    Page<AnimalResDTO> findAll(PageDTO pageDTO);
    AnimalResDTO create (AnimalReqDTO animalReqDTO, MultipartFile imagem) throws IOException;
    AnimalResDTO update (String id, AnimalReqDTO animalReqDTO,  MultipartFile imagem) throws IOException;
    void delete (String id);
    Optional<AnimalResDTO> findByUsuarioId(String usuarioId);

    String saveImage (MultipartFile file) throws IOException;
}

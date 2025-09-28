package com.petdex.api.view;

import com.petdex.api.application.services.animal.IAnimalService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.animal.AnimalReqDTO;
import com.petdex.api.domain.contracts.dto.animal.AnimalResDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/animais")
@Tag(name = "Animal", description = "Operações de gestão envolvendo animais")
public class AnimalController {

    @Autowired
    IAnimalService animalService;

    @GetMapping("/{id}")
    public ResponseEntity<AnimalResDTO> findById (@PathVariable String id) {
        return new ResponseEntity<>(
                animalService.findById(id),
                HttpStatus.OK
        );
    }

    @GetMapping
    public ResponseEntity<Page<AnimalResDTO>> findAll (@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                animalService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(summary = "Cadastrar um animal")
    @PostMapping
    public ResponseEntity<AnimalResDTO> create (@RequestBody AnimalReqDTO animalReqDTO) {
        return new ResponseEntity<>(
                animalService.create(animalReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(summary = "Atualizar o cadastro de um animal")
    @PutMapping("/{id}")
    public ResponseEntity<AnimalResDTO> update (@PathVariable String id, @RequestBody AnimalReqDTO animalReqDTO) {
        return new ResponseEntity<>(
                animalService.update(id, animalReqDTO),
                HttpStatus.CREATED
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete (@PathVariable String id) {
        animalService.delete(id);
        return new ResponseEntity<>("Animal deletado",HttpStatus.OK);
    }
}

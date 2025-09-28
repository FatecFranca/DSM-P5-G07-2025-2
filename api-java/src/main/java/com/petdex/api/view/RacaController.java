package com.petdex.api.view;

import com.petdex.api.application.services.raca.RacaService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaReqDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaResDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/racas")
@Tag(name = "Raca", description = "Operações de gestão envolvendo racas")
public class RacaController {

    @Autowired
    RacaService racaService;

    @GetMapping("/{id}")
    public ResponseEntity<RacaResDTO> findById(@PathVariable String id) {
        return new ResponseEntity<>(
                racaService.findById(id), HttpStatus.OK
        );
    }

    @GetMapping()
    public ResponseEntity<Page<RacaResDTO>> findAll (@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                racaService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(summary = "Cadastrar uma nova raça")
    @PostMapping
    public ResponseEntity<RacaResDTO> create (@RequestBody RacaReqDTO racaReqDTO) {
        return new ResponseEntity(
                racaService.create(racaReqDTO),
                HttpStatus.CREATED
        );
    }


    @Operation(summary = "Atualizar o cadastro de uma raça")
    @PutMapping("/{id}")
    public ResponseEntity<RacaResDTO> update (@PathVariable String id, @RequestBody RacaReqDTO racaReqDTO){
        return new ResponseEntity<>(
                racaService.update(id, racaReqDTO),
                HttpStatus.CREATED
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete (@PathVariable String id) {
        racaService.delete(id);
        return new ResponseEntity<>(
                "Raça deletada com sucesso!",
                HttpStatus.OK
        );
    }
}

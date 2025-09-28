package com.petdex.api.view;

import com.petdex.api.application.services.especie.IEspecieService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.especie.EspecieReqDTO;
import com.petdex.api.domain.contracts.dto.especie.EspecieResDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/especies")
@Tag(name = "Especie", description = "Operações de gestão envolvendo especies")
public class EspecieController {

    @Autowired
    IEspecieService especieService;

    @GetMapping("/{id}")
    public ResponseEntity<EspecieResDTO> findById(@PathVariable String id) {
        return new ResponseEntity(especieService.findById(id),
                HttpStatus.OK);
    }

    @GetMapping()
    public ResponseEntity<Page<EspecieResDTO>> findAll(@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                especieService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(summary = "Cadastrar uma nova espécie")
    @PostMapping()
    public ResponseEntity<EspecieResDTO> create (@RequestBody EspecieReqDTO especieReqDTO) {
        return new ResponseEntity<>(
                especieService.create(especieReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(summary = "Atualizar o cadastro de uma especie")
    @PutMapping("/{id}")
    public ResponseEntity<EspecieResDTO> update (@PathVariable String id, @RequestBody EspecieReqDTO especieReqDTO) {
        return new ResponseEntity<>(
                especieService.update(id, especieReqDTO),
                HttpStatus.CREATED
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete (@PathVariable String id) {
        especieService.delete(id);
        return new ResponseEntity<>(
                "Especie deletada com sucesso",
                HttpStatus.OK
        );
    }
}

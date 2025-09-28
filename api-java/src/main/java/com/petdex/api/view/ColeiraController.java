package com.petdex.api.view;

import com.petdex.api.application.services.coleira.IColeiraService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.coleira.ColeiraReqDTO;
import com.petdex.api.domain.contracts.dto.coleira.ColeiraResDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/coleiras")
@Tag(name = "Coleira", description = "Operações de gestão envolvendo coleiras")
public class ColeiraController {

    @Autowired
    IColeiraService coleiraService;

    @GetMapping("/{id}")
    public ResponseEntity<ColeiraResDTO> findById(@PathVariable String id) {
        return new ResponseEntity<>(
                coleiraService.findById(id),
                HttpStatus.OK
        );
    }

    @GetMapping
    public ResponseEntity<Page<ColeiraResDTO>> findAll(@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                coleiraService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(summary = "Criar uma nova coleira")
    @PostMapping
    public ResponseEntity<ColeiraResDTO> create(@RequestBody ColeiraReqDTO coleiraReqDTO) {
        return new ResponseEntity<>(
                coleiraService.create(coleiraReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(summary = "Atualizar uma coleira existente")
    @PutMapping("/{id}")
    ResponseEntity<ColeiraResDTO> update(@PathVariable String id, @RequestBody ColeiraReqDTO coleiraReqDTO) {
        return new ResponseEntity<>(
                coleiraService.update(id, coleiraReqDTO),
                HttpStatus.CREATED
        );
    }

    @DeleteMapping("/{id}")
    ResponseEntity<String> delete(@PathVariable String id) {
        coleiraService.delete(id);
        return new ResponseEntity<>("Deletado com sucesso", HttpStatus.OK);
    }

}

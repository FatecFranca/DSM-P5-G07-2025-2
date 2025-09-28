package com.petdex.api.view;

import com.petdex.api.application.services.batimento.IBatimentoService;
import com.petdex.api.domain.contracts.dto.batimento.BatimentoReqDTO;
import com.petdex.api.domain.contracts.dto.batimento.BatimentoResDTO;
import com.petdex.api.domain.contracts.dto.PageDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/batimentos")
@Tag(name = "Batimentos", description = "Operações de gestão de batimentos cardíacos do animal")
public class BatimentoController {


    @Autowired
    private IBatimentoService batimentoService;

    @Operation(
            summary = "Consultar batimento cardíaco pelo id",
            parameters = {
                    @Parameter(name = "idBatimento", description = "ID do batimento que se deseja consultar", required = true)
            }
    )
    @GetMapping("/{idBatimento}")
    public ResponseEntity<BatimentoResDTO> findById(@PathVariable String idBatimento) {
        return new ResponseEntity<>(
                batimentoService.fidById(idBatimento), HttpStatus.OK
        );
    }


    @Operation(
            summary = "Consultar batimentos cardíacos pelo id do animal",
            parameters = {
                    @Parameter(name = "idAnimal", description = "ID do animal que se deseja consultar os batimentos", required = true)
            }
    )
    @GetMapping("/animal/{idAnimal}")
    public ResponseEntity<Page<BatimentoResDTO>> findAllByAnimal(@PathVariable String idAnimal, @ParameterObject @ModelAttribute PageDTO pageDTO) {
        return new ResponseEntity<>(batimentoService.findAllByAnimalId(idAnimal, pageDTO),
            HttpStatus.OK
        );
    }

    @Operation(summary = "Consultar batimentos cardíacos pelo id da coleira",
            parameters = {
                    @Parameter(name = "idColeira", description = "ID da coleira que se deseja consultar os batimentos cardíacos")
            }
    )
    @GetMapping("/coleira/{idColeira}")
    public ResponseEntity<Page<BatimentoResDTO>> findAllByColeira(@PathVariable String idColeira, @ParameterObject @ModelAttribute PageDTO pageDTO) {
        return new ResponseEntity<>(
                batimentoService.findAllByColeiraId(idColeira, pageDTO),
                HttpStatus.OK
        );
    }

    @PostMapping("")
    public ResponseEntity<BatimentoResDTO> save (@RequestBody BatimentoReqDTO batimento) {
        return new ResponseEntity<BatimentoResDTO>(batimentoService.save(batimento), HttpStatus.CREATED);
    }

}

package com.petdex.api.view;

import com.petdex.api.application.services.movimento.IMovimentoService;
import com.petdex.api.domain.contracts.dto.movimento.MovimentoReqDTO;
import com.petdex.api.domain.contracts.dto.movimento.MovimentoResDTO;
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
@Tag(name = "Movimento", description = "Operações de gestão de movimentos dos animais")
@RequestMapping("/movimentos")
public class MovimentoController {
    @Autowired
    private IMovimentoService movimentoService;

    @Operation(
            summary = "Consultar batimento cardíaco pelo id",
            parameters = {
                    @Parameter(name = "idMovimento", description = "ID do batimento que se deseja consultar", required = true)
            }
    )
    @GetMapping("/{idMovimento}")
    public ResponseEntity<MovimentoResDTO> findById(@PathVariable String idMovimento) {
        return new ResponseEntity<>(
                movimentoService.fidById(idMovimento), HttpStatus.OK
        );
    }


    @Operation(
            summary = "Consultar movimentos pelo id do animal",
            parameters = {
                    @Parameter(name = "idAnimal", description = "ID do animal que se deseja consultar os movimentos", required = true)
            }
    )
    @GetMapping("/animal/{idAnimal}")
    public ResponseEntity<Page<MovimentoResDTO>> findAllByAnimal(@PathVariable String idAnimal, @ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(movimentoService.findAllByAnimalId(idAnimal, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(summary = "Consultar batimentos cardíacos pelo id da coleira",
            parameters = {
                    @Parameter(name = "idColeira", description = "ID da coleira que se deseja consultar os batimentos cardíacos")
            }
    )
    @GetMapping("/coleira/{idColeira}")
    public ResponseEntity<Page<MovimentoResDTO>> findAllByColeira(@PathVariable String idColeira, @ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                movimentoService.findAllByColeiraId(idColeira, pageDTO),
                HttpStatus.OK
        );
    }

    @PostMapping("")
    public ResponseEntity<MovimentoResDTO> save (@RequestBody MovimentoReqDTO movimento) {
        return new ResponseEntity<MovimentoResDTO>(movimentoService.save(movimento), HttpStatus.CREATED);
    }
}

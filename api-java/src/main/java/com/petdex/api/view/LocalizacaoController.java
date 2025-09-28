package com.petdex.api.view;

import com.petdex.api.application.services.localizacao.ILocalizacaoService;
import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoReqDTO;
import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoResDTO;
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
@Tag(name = "Localizacao", description = "Operações de gestão de localizações dos animais")
@RequestMapping("/localizacoes")
public class LocalizacaoController {

    @Autowired
    private ILocalizacaoService localizacaoService;

    @Operation(
            summary = "Consultar batimento cardíaco pelo id",
            parameters = {
                    @Parameter(name = "idLocalizacao", description = "ID do batimento que se deseja consultar", required = true)
            }
    )
    @GetMapping("/{idLocalizacao}")
    public ResponseEntity<LocalizacaoResDTO> findById(@PathVariable String idLocalizacao) {
        return new ResponseEntity<>(
                localizacaoService.fidById(idLocalizacao), HttpStatus.OK
        );
    }


    @Operation(
            summary = "Consultar localizacaos pelo id do animal",
            parameters = {
                    @Parameter(name = "idAnimal", description = "ID do animal que se deseja consultar os localizacaos", required = true)
            }
    )
    @GetMapping("/animal/{idAnimal}")
    public ResponseEntity<Page<LocalizacaoResDTO>> findAllByAnimal(@PathVariable String idAnimal, @ParameterObject PageDTO pageDTO) {

        return new ResponseEntity<>(localizacaoService.findAllByAnimalId(idAnimal, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(summary = "Consultar batimentos cardíacos pelo id da coleira",
            parameters = {
                    @Parameter(name = "idColeira", description = "ID da coleira que se deseja consultar os batimentos cardíacos")
            }
    )
    @GetMapping("/coleira/{idColeira}")
    public ResponseEntity<Page<LocalizacaoResDTO>> findAllByColeira(@PathVariable String idColeira, @ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                localizacaoService.findAllByColeiraId(idColeira, pageDTO),
                HttpStatus.OK
        );
    }

    @PostMapping("")
    public ResponseEntity<LocalizacaoResDTO> save (@RequestBody LocalizacaoReqDTO localizacao) {
        return new ResponseEntity<LocalizacaoResDTO>(localizacaoService.save(localizacao), HttpStatus.CREATED);
    }
}

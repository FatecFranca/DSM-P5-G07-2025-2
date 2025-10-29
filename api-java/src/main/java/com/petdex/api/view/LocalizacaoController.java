package com.petdex.api.view;

import com.petdex.api.application.services.localizacao.ILocalizacaoService;
import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoReqDTO;
import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoResDTO;
import com.petdex.api.domain.contracts.dto.PageDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
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
            summary = "Consultar localização pelo ID",
            description = "Retorna os detalhes de um registro de localização específico através do seu identificador único",
            parameters = {
                    @Parameter(name = "idLocalizacao", description = "ID da localização que se deseja consultar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Localização encontrada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = LocalizacaoResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Localização não encontrada",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/{idLocalizacao}")
    public ResponseEntity<LocalizacaoResDTO> findById(@PathVariable String idLocalizacao) {
        return new ResponseEntity<>(
                localizacaoService.fidById(idLocalizacao), HttpStatus.OK
        );
    }


    @Operation(
            summary = "Consultar localizações pelo ID do animal",
            description = "Retorna uma lista paginada de todas as localizações registradas para um animal específico",
            parameters = {
                    @Parameter(name = "idAnimal", description = "ID do animal que se deseja consultar as localizações", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de localizações retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/animal/{idAnimal}")
    public ResponseEntity<Page<LocalizacaoResDTO>> findAllByAnimal(@PathVariable String idAnimal, @ParameterObject PageDTO pageDTO) {

        return new ResponseEntity<>(localizacaoService.findAllByAnimalId(idAnimal, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar localizações pelo ID da coleira",
            description = "Retorna uma lista paginada de todas as localizações registradas por uma coleira específica",
            parameters = {
                    @Parameter(name = "idColeira", description = "ID da coleira que se deseja consultar as localizações", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de localizações retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/coleira/{idColeira}")
    public ResponseEntity<Page<LocalizacaoResDTO>> findAllByColeira(@PathVariable String idColeira, @ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                localizacaoService.findAllByColeiraId(idColeira, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Buscar a última localização registrada de um animal",
            description = "Retorna a localização mais recente de um animal específico, ordenada por data de registro",
            parameters = {
                    @Parameter(name = "idAnimal", description = "ID do animal que se deseja consultar a última localização", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Última localização encontrada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = LocalizacaoResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Nenhuma localização encontrada para o animal",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/animal/{idAnimal}/ultima")
    public ResponseEntity<LocalizacaoResDTO> findLastByAnimal(@PathVariable String idAnimal) {
        return localizacaoService.findLastByAnimalId(idAnimal)
                .map(localizacao -> new ResponseEntity<>(localizacao, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @Operation(
            summary = "Registrar uma nova localização",
            description = "Cria um novo registro de localização no sistema. É necessário informar o ID do animal ou coleira e as coordenadas geográficas."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Localização registrada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = LocalizacaoResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PostMapping("")
    public ResponseEntity<LocalizacaoResDTO> save (@RequestBody LocalizacaoReqDTO localizacao) {
        return new ResponseEntity<LocalizacaoResDTO>(localizacaoService.save(localizacao), HttpStatus.CREATED);
    }
}

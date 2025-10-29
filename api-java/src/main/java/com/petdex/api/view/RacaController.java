package com.petdex.api.view;

import com.petdex.api.application.services.raca.RacaService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaReqDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaResDTO;
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
@RequestMapping("/racas")
@Tag(name = "Raca", description = "Operações de gestão envolvendo racas")
public class RacaController {

    @Autowired
    RacaService racaService;

    @Operation(
            summary = "Buscar raça por ID",
            description = "Retorna os detalhes de uma raça específica através do seu identificador único",
            parameters = {
                    @Parameter(name = "id", description = "ID da raça que se deseja consultar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Raça encontrada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = RacaResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Raça não encontrada",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<RacaResDTO> findById(@PathVariable String id) {
        return new ResponseEntity<>(
                racaService.findById(id), HttpStatus.OK
        );
    }

    @Operation(
            summary = "Listar todas as raças",
            description = "Retorna uma lista paginada de todas as raças cadastradas no sistema. " +
                    "É possível ordenar e filtrar os resultados através dos parâmetros de paginação."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de raças retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping()
    public ResponseEntity<Page<RacaResDTO>> findAll (@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                racaService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Cadastrar uma nova raça",
            description = "Cria uma nova raça no sistema. É necessário informar o nome da raça e a espécie à qual ela pertence."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Raça criada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = RacaResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PostMapping
    public ResponseEntity<RacaResDTO> create (@RequestBody RacaReqDTO racaReqDTO) {
        return new ResponseEntity(
                racaService.create(racaReqDTO),
                HttpStatus.CREATED
        );
    }


    @Operation(
            summary = "Atualizar o cadastro de uma raça",
            description = "Atualiza as informações de uma raça existente no sistema através do seu ID",
            parameters = {
                    @Parameter(name = "id", description = "ID da raça que se deseja atualizar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Raça atualizada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = RacaResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "404", description = "Raça não encontrada",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<RacaResDTO> update (@PathVariable String id, @RequestBody RacaReqDTO racaReqDTO){
        return new ResponseEntity<>(
                racaService.update(id, racaReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Deletar uma raça",
            description = "Remove uma raça do sistema através do seu ID",
            parameters = {
                    @Parameter(name = "id", description = "ID da raça que se deseja deletar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Raça deletada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = String.class))),
            @ApiResponse(responseCode = "404", description = "Raça não encontrada",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete (@PathVariable String id) {
        racaService.delete(id);
        return new ResponseEntity<>(
                "Raça deletada com sucesso!",
                HttpStatus.OK
        );
    }
}

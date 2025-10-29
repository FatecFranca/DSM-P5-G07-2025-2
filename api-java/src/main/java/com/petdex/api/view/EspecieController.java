package com.petdex.api.view;

import com.petdex.api.application.services.especie.IEspecieService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.especie.EspecieReqDTO;
import com.petdex.api.domain.contracts.dto.especie.EspecieResDTO;
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
@RequestMapping("/especies")
@Tag(name = "Especie", description = "Operações de gestão envolvendo especies")
public class EspecieController {

    @Autowired
    IEspecieService especieService;

    @Operation(
            summary = "Buscar espécie por ID",
            description = "Retorna os detalhes de uma espécie específica através do seu identificador único",
            parameters = {
                    @Parameter(name = "id", description = "ID da espécie que se deseja consultar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Espécie encontrada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = EspecieResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Espécie não encontrada",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<EspecieResDTO> findById(@PathVariable String id) {
        return new ResponseEntity(especieService.findById(id),
                HttpStatus.OK);
    }

    @Operation(
            summary = "Listar todas as espécies",
            description = "Retorna uma lista paginada de todas as espécies cadastradas no sistema. " +
                    "É possível ordenar e filtrar os resultados através dos parâmetros de paginação."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de espécies retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping()
    public ResponseEntity<Page<EspecieResDTO>> findAll(@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                especieService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Cadastrar uma nova espécie",
            description = "Cria uma nova espécie no sistema. É necessário informar o nome da espécie."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Espécie criada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = EspecieResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PostMapping()
    public ResponseEntity<EspecieResDTO> create (@RequestBody EspecieReqDTO especieReqDTO) {
        return new ResponseEntity<>(
                especieService.create(especieReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Atualizar o cadastro de uma espécie",
            description = "Atualiza as informações de uma espécie existente no sistema através do seu ID",
            parameters = {
                    @Parameter(name = "id", description = "ID da espécie que se deseja atualizar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Espécie atualizada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = EspecieResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "404", description = "Espécie não encontrada",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<EspecieResDTO> update (@PathVariable String id, @RequestBody EspecieReqDTO especieReqDTO) {
        return new ResponseEntity<>(
                especieService.update(id, especieReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Deletar uma espécie",
            description = "Remove uma espécie do sistema através do seu ID",
            parameters = {
                    @Parameter(name = "id", description = "ID da espécie que se deseja deletar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Espécie deletada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = String.class))),
            @ApiResponse(responseCode = "404", description = "Espécie não encontrada",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete (@PathVariable String id) {
        especieService.delete(id);
        return new ResponseEntity<>(
                "Especie deletada com sucesso",
                HttpStatus.OK
        );
    }
}

package com.petdex.api.view;

import com.petdex.api.application.services.coleira.IColeiraService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.coleira.ColeiraReqDTO;
import com.petdex.api.domain.contracts.dto.coleira.ColeiraResDTO;
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
@RequestMapping("/coleiras")
@Tag(name = "Coleira", description = "Operações de gestão envolvendo coleiras")
public class ColeiraController {

    @Autowired
    IColeiraService coleiraService;

    @Operation(
            summary = "Buscar coleira por ID",
            description = "Retorna os detalhes de uma coleira específica através do seu identificador único",
            parameters = {
                    @Parameter(name = "id", description = "ID da coleira que se deseja consultar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Coleira encontrada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ColeiraResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Coleira não encontrada",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<ColeiraResDTO> findById(@PathVariable String id) {
        return new ResponseEntity<>(
                coleiraService.findById(id),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Listar todas as coleiras",
            description = "Retorna uma lista paginada de todas as coleiras cadastradas no sistema. " +
                    "É possível ordenar e filtrar os resultados através dos parâmetros de paginação."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de coleiras retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<ColeiraResDTO>> findAll(@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                coleiraService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Criar uma nova coleira",
            description = "Cria uma nova coleira no sistema. É necessário informar os dados da coleira incluindo número de série e informações do dispositivo."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Coleira criada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ColeiraResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PostMapping
    public ResponseEntity<ColeiraResDTO> create(@RequestBody ColeiraReqDTO coleiraReqDTO) {
        return new ResponseEntity<>(
                coleiraService.create(coleiraReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Atualizar uma coleira existente",
            description = "Atualiza as informações de uma coleira existente no sistema através do seu ID",
            parameters = {
                    @Parameter(name = "id", description = "ID da coleira que se deseja atualizar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Coleira atualizada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ColeiraResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "404", description = "Coleira não encontrada",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PutMapping("/{id}")
    ResponseEntity<ColeiraResDTO> update(@PathVariable String id, @RequestBody ColeiraReqDTO coleiraReqDTO) {
        return new ResponseEntity<>(
                coleiraService.update(id, coleiraReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Deletar uma coleira",
            description = "Remove uma coleira do sistema através do seu ID",
            parameters = {
                    @Parameter(name = "id", description = "ID da coleira que se deseja deletar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Coleira deletada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = String.class))),
            @ApiResponse(responseCode = "404", description = "Coleira não encontrada",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @DeleteMapping("/{id}")
    ResponseEntity<String> delete(@PathVariable String id) {
        coleiraService.delete(id);
        return new ResponseEntity<>("Deletado com sucesso", HttpStatus.OK);
    }

}

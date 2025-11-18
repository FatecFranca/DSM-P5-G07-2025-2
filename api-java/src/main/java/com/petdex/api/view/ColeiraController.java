package com.petdex.api.view;

import com.petdex.api.application.services.coleira.IColeiraService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.coleira.ColeiraReqDTO;
import com.petdex.api.domain.contracts.dto.coleira.ColeiraResDTO;
import com.petdex.api.swagger.respostas.ExemploRespostaDeletarColeira;
import com.petdex.api.swagger.respostas.ExemploRespostaPageColeira;
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
            summary = "Consultar coleira",
            description = "Consulta os detalhes de uma coleira específica através do seu identificador único",
            tags = {"Coleira"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador da coleira que será consultada", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ColeiraResDTO.class)
                            )
                    )
            }
    )
    @GetMapping("/{id}")
    public ResponseEntity<ColeiraResDTO> findById(@PathVariable String id) {
        return new ResponseEntity<>(
                coleiraService.findById(id),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar todas as coleiras",
            description = "Consulta uma lista paginada de todas as coleiras cadastradas no sistema. " +
                         "É possível ordenar os resultados através dos parâmetros de paginação.",
            tags = {"Coleira"},
            parameters = {
                    @Parameter(name = "page", description = "Número da página que será feita a requisição", example = "0", schema = @Schema(implementation = Integer.class)),
                    @Parameter(name = "size", description = "Quantidade máxima de elementos por página", example = "10", schema = @Schema(implementation = Integer.class)),
                    @Parameter(
                            name = "sortBy",
                            description = "Atributo pelo qual os resultados serão ordenados.\n\n" +
                                    "**Atributos disponíveis**\n" +
                                    "- **descricao**: Descrição da coleira\n" +
                                    "- **animal**: ID do animal associado",
                            example = "descricao",
                            schema = @Schema(implementation = String.class)
                    ),
                    @Parameter(
                            name = "direction",
                            description = "Direção da ordenação.\n\n" +
                                    "**Valores disponíveis**\n" +
                                    "- **asc**: Ordena de forma ascendente\n" +
                                    "- **desc**: Ordena de forma descendente",
                            example = "asc",
                            schema = @Schema(implementation = String.class)
                    )
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ExemploRespostaPageColeira.class)
                            )
                    )
            }
    )
    @GetMapping
    public ResponseEntity<Page<ColeiraResDTO>> findAll(@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                coleiraService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Criar coleira",
            description = "Cria uma nova coleira no sistema. É necessário informar a descrição da coleira e o ID do animal ao qual ela será associada.",
            tags = {"Coleira"},
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados da coleira que será criada no sistema",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = ColeiraReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "201",
                            description = "Coleira criada com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ColeiraResDTO.class)
                            )
                    )
            }
    )
    @PostMapping
    public ResponseEntity<ColeiraResDTO> create(@RequestBody ColeiraReqDTO coleiraReqDTO) {
        return new ResponseEntity<>(
                coleiraService.create(coleiraReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Atualizar coleira",
            description = "Atualiza as informações de uma coleira existente no sistema através do seu identificador único. " +
                         "É possível atualizar a descrição e/ou o animal associado à coleira.",
            tags = {"Coleira"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador da coleira que será atualizada", required = true, example = "507f1f77bcf86cd799439011")
            },
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados atualizados da coleira",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = ColeiraReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Coleira atualizada com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ColeiraResDTO.class)
                            )
                    )
            }
    )
    @PutMapping("/{id}")
    ResponseEntity<ColeiraResDTO> update(@PathVariable String id, @RequestBody ColeiraReqDTO coleiraReqDTO) {
        return new ResponseEntity<>(
                coleiraService.update(id, coleiraReqDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Deletar coleira",
            description = "Remove uma coleira do sistema através do seu identificador único",
            tags = {"Coleira"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador da coleira que será deletada", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Coleira deletada com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ExemploRespostaDeletarColeira.class)
                            )
                    )
            }
    )
    @DeleteMapping("/{id}")
    ResponseEntity<String> delete(@PathVariable String id) {
        coleiraService.delete(id);
        return new ResponseEntity<>("Deletado com sucesso", HttpStatus.OK);
    }

}

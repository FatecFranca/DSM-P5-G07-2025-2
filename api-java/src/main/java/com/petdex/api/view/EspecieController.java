package com.petdex.api.view;

import com.petdex.api.application.services.especie.IEspecieService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.especie.EspecieReqDTO;
import com.petdex.api.domain.contracts.dto.especie.EspecieResDTO;
import com.petdex.api.swagger.respostas.ExemploRespostaDeletarEspecie;
import com.petdex.api.swagger.respostas.ExemploRespostaPageEspecie;
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
            summary = "Consultar espécie",
            description = "Consulta os detalhes de uma espécie específica através do seu identificador único",
            tags = {"Especie"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador da espécie que será consultada", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = EspecieResDTO.class)
                            )
                    )
            }
    )
    @GetMapping("/{id}")
    public ResponseEntity<EspecieResDTO> findById(@PathVariable String id) {
        return new ResponseEntity(especieService.findById(id),
                HttpStatus.OK);
    }

    @Operation(
            summary = "Consultar espécies",
            description = "Consulta uma lista paginada de todas as espécies cadastradas no sistema",
            tags = {"Especie"},
            parameters = {
                    @Parameter(name = "page", description = "Número da página que será feita a requisição", example = "0", schema = @Schema(implementation = Integer.class)),
                    @Parameter(name = "size", description = "Quantidade máxima de elementos por página", example = "10", schema = @Schema(implementation = Integer.class)),
                    @Parameter(
                            name = "sortBy",
                            description = "Atributo pelo qual as respostas serão ordenadas.\n\n" +
                                    "**Atributos disponíveis para ordenação**\n" +
                                    "- **nome**: Ordena pelo nome da espécie\n" +
                                    "- **id**: Ordena pelo código identificador da espécie",
                            example = "nome",
                            schema = @Schema(implementation = String.class)
                    ),
                    @Parameter(
                            name = "direction",
                            description = "Direção da ordenação das respostas.\n\n" +
                                    "**Direções disponíveis**\n" +
                                    "- **asc**: Ordena de forma ascendente pelo atributo definido\n" +
                                    "- **desc**: Ordena de forma descendente pelo atributo definido",
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
                                    schema = @Schema(implementation = ExemploRespostaPageEspecie.class)
                            )
                    )
            }
    )
    @GetMapping()
    public ResponseEntity<Page<EspecieResDTO>> findAll(@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                especieService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Cadastrar espécie",
            description = "Cadastra uma nova espécie no sistema",
            tags = {"Especie"},
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados da espécie que será cadastrada",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = EspecieReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "201",
                            description = "Espécie criada com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = EspecieResDTO.class)
                            )
                    )
            }
    )
    @PostMapping()
    public ResponseEntity<EspecieResDTO> create (@RequestBody EspecieReqDTO especieReqDTO) {
        return new ResponseEntity<>(
                especieService.create(especieReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Atualizar espécie",
            description = "Atualiza as informações de uma espécie existente no sistema através do seu identificador único",
            tags = {"Especie"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador da espécie que será atualizada", required = true, example = "507f1f77bcf86cd799439011")
            },
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados atualizados da espécie",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = EspecieReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Espécie atualizada com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = EspecieResDTO.class)
                            )
                    )
            }
    )
    @PutMapping("/{id}")
    public ResponseEntity<EspecieResDTO> update (@PathVariable String id, @RequestBody EspecieReqDTO especieReqDTO) {
        return new ResponseEntity<>(
                especieService.update(id, especieReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Deletar espécie",
            description = "Remove uma espécie do sistema através do seu identificador único",
            tags = {"Especie"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador da espécie que será deletada", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Espécie deletada com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ExemploRespostaDeletarEspecie.class)
                            )
                    )
            }
    )
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete (@PathVariable String id) {
        especieService.delete(id);
        return new ResponseEntity<>(
                "Especie deletada com sucesso",
                HttpStatus.OK
        );
    }
}

package com.petdex.api.view;

import com.petdex.api.application.services.raca.RacaService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaReqDTO;
import com.petdex.api.domain.contracts.dto.raca.RacaResDTO;
import com.petdex.api.swagger.respostas.ExemploRespostaDeletarRaca;
import com.petdex.api.swagger.respostas.ExemploRespostaPageRaca;
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
            summary = "Consultar raça",
            description = "Consulta os detalhes de uma raça específica através do seu identificador único",
            tags = {"Raca"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador da raça que será consultada", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = RacaResDTO.class)
                            )
                    )
            }
    )
    @GetMapping("/{id}")
    public ResponseEntity<RacaResDTO> findById(@PathVariable String id) {
        return new ResponseEntity<>(
                racaService.findById(id), HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar raças",
            description = "Consulta uma lista paginada de todas as raças cadastradas no sistema",
            tags = {"Raca"},
            parameters = {
                    @Parameter(name = "page", description = "Número da página que será feita a requisição", example = "0", schema = @Schema(implementation = Integer.class)),
                    @Parameter(name = "size", description = "Quantidade máxima de elementos por página", example = "10", schema = @Schema(implementation = Integer.class)),
                    @Parameter(
                            name = "sortBy",
                            description = "Atributo pelo qual as respostas serão ordenadas.\n\n" +
                                    "**Atributos disponíveis para ordenação**\n" +
                                    "- **nome**: Ordena pelo nome da raça\n" +
                                    "- **id**: Ordena pelo código identificador da raça",
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
                                    schema = @Schema(implementation = ExemploRespostaPageRaca.class)
                            )
                    )
            }
    )
    @GetMapping()
    public ResponseEntity<Page<RacaResDTO>> findAll (@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                racaService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Cadastrar raça",
            description = "Cadastra uma nova raça no sistema",
            tags = {"Raca"},
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados da raça que será cadastrada",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = RacaReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "201",
                            description = "Raça cadastrada com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = RacaResDTO.class)
                            )
                    )
            }
    )
    @PostMapping
    public ResponseEntity<RacaResDTO> create (@RequestBody RacaReqDTO racaReqDTO) {
        return new ResponseEntity(
                racaService.create(racaReqDTO),
                HttpStatus.CREATED
        );
    }


    @Operation(
            summary = "Atualizar raça",
            description = "Atualiza as informações de uma raça existente no sistema",
            tags = {"Raca"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador da raça que será atualizada", required = true, example = "507f1f77bcf86cd799439011")
            },
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados atualizados da raça",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = RacaReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Raça atualizada com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = RacaResDTO.class)
                            )
                    )
            }
    )
    @PutMapping("/{id}")
    public ResponseEntity<RacaResDTO> update (@PathVariable String id, @RequestBody RacaReqDTO racaReqDTO){
        return new ResponseEntity<>(
                racaService.update(id, racaReqDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Deletar raça",
            description = "Remove uma raça do sistema",
            tags = {"Raca"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador da raça que será deletada", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Raça deletada com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ExemploRespostaDeletarRaca.class)
                            )
                    )
            }
    )
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete (@PathVariable String id) {
        racaService.delete(id);
        return new ResponseEntity<>(
                "Raça deletada com sucesso!",
                HttpStatus.OK
        );
    }
}

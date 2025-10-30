package com.petdex.api.view;

import com.petdex.api.application.services.movimento.IMovimentoService;
import com.petdex.api.domain.contracts.dto.movimento.MovimentoReqDTO;
import com.petdex.api.domain.contracts.dto.movimento.MovimentoResDTO;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.swagger.respostas.ExemploRespostaPageMovimento;
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
@Tag(name = "Movimento", description = "Operações de gestão de movimentos dos animais")
@RequestMapping("/movimentos")
public class MovimentoController {
    @Autowired
    private IMovimentoService movimentoService;

    @Operation(
            summary = "Consultar movimento",
            description = "Consulta os detalhes de um registro de movimento específico através do seu identificador único",
            tags = {"Movimento"},
            parameters = {
                    @Parameter(name = "idMovimento", description = "Código identificador do movimento que será consultado", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = MovimentoResDTO.class)
                            )
                    )
            }
    )
    @GetMapping("/{idMovimento}")
    public ResponseEntity<MovimentoResDTO> findById(@PathVariable String idMovimento) {
        return new ResponseEntity<>(
                movimentoService.fidById(idMovimento), HttpStatus.OK
        );
    }


    @Operation(
            summary = "Consultar movimentos por animal",
            description = "Consulta uma lista paginada de todos os movimentos registrados para um animal específico",
            tags = {"Movimento"},
            parameters = {
                    @Parameter(name = "idAnimal", description = "Código identificador do animal que terá os movimentos consultados", required = true, example = "507f1f77bcf86cd799439011"),
                    @Parameter(name = "page", description = "Número da página que será feita a requisição", example = "0", schema = @Schema(implementation = Integer.class)),
                    @Parameter(name = "size", description = "Quantidade máxima de elementos por página", example = "10", schema = @Schema(implementation = Integer.class)),
                    @Parameter(
                            name = "sortBy",
                            description = "Atributo pelo qual as respostas serão ordenadas.\n\n" +
                                    "**Atributos disponíveis para ordenação**\n" +
                                    "- **data**: Ordena pela data e hora da coleta do movimento\n" +
                                    "- **acelerometroX**: Ordena pelo valor de aceleração no eixo X\n" +
                                    "- **acelerometroY**: Ordena pelo valor de aceleração no eixo Y\n" +
                                    "- **acelerometroZ**: Ordena pelo valor de aceleração no eixo Z\n" +
                                    "- **giroscopioX**: Ordena pelo valor de rotação do giroscópio no eixo X\n" +
                                    "- **giroscopioY**: Ordena pelo valor de rotação do giroscópio no eixo Y\n" +
                                    "- **giroscopioZ**: Ordena pelo valor de rotação do giroscópio no eixo Z\n" +
                                    "- **id**: Ordena pelo código identificador do movimento",
                            example = "data",
                            schema = @Schema(implementation = String.class)
                    ),
                    @Parameter(
                            name = "direction",
                            description = "Direção da ordenação das respostas.\n\n" +
                                    "**Direções disponíveis**\n" +
                                    "- **asc**: Ordena de forma ascendente pelo atributo definido\n" +
                                    "- **desc**: Ordena de forma descendente pelo atributo definido",
                            example = "desc",
                            schema = @Schema(implementation = String.class)
                    )
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ExemploRespostaPageMovimento.class)
                            )
                    )
            }
    )
    @GetMapping("/animal/{idAnimal}")
    public ResponseEntity<Page<MovimentoResDTO>> findAllByAnimal(@PathVariable String idAnimal, @ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(movimentoService.findAllByAnimalId(idAnimal, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar movimentos por coleira",
            description = "Consulta uma lista paginada de todos os movimentos registrados por uma coleira específica",
            tags = {"Movimento"},
            parameters = {
                    @Parameter(name = "idColeira", description = "Código identificador da coleira que terá os movimentos consultados", required = true, example = "507f1f77bcf86cd799439011"),
                    @Parameter(name = "page", description = "Número da página que será feita a requisição", example = "0", schema = @Schema(implementation = Integer.class)),
                    @Parameter(name = "size", description = "Quantidade máxima de elementos por página", example = "10", schema = @Schema(implementation = Integer.class)),
                    @Parameter(
                            name = "sortBy",
                            description = "Atributo pelo qual as respostas serão ordenadas.\n\n" +
                                    "**Atributos disponíveis para ordenação**\n" +
                                    "- **data**: Ordena pela data e hora da coleta do movimento\n" +
                                    "- **acelerometroX**: Ordena pelo valor de aceleração no eixo X\n" +
                                    "- **acelerometroY**: Ordena pelo valor de aceleração no eixo Y\n" +
                                    "- **acelerometroZ**: Ordena pelo valor de aceleração no eixo Z\n" +
                                    "- **giroscopioX**: Ordena pelo valor de rotação do giroscópio no eixo X\n" +
                                    "- **giroscopioY**: Ordena pelo valor de rotação do giroscópio no eixo Y\n" +
                                    "- **giroscopioZ**: Ordena pelo valor de rotação do giroscópio no eixo Z\n" +
                                    "- **id**: Ordena pelo código identificador do movimento",
                            example = "data",
                            schema = @Schema(implementation = String.class)
                    ),
                    @Parameter(
                            name = "direction",
                            description = "Direção da ordenação das respostas.\n\n" +
                                    "**Direções disponíveis**\n" +
                                    "- **asc**: Ordena de forma ascendente pelo atributo definido\n" +
                                    "- **desc**: Ordena de forma descendente pelo atributo definido",
                            example = "desc",
                            schema = @Schema(implementation = String.class)
                    )
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ExemploRespostaPageMovimento.class)
                            )
                    )
            }
    )
    @GetMapping("/coleira/{idColeira}")
    public ResponseEntity<Page<MovimentoResDTO>> findAllByColeira(@PathVariable String idColeira, @ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                movimentoService.findAllByColeiraId(idColeira, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Registrar movimento",
            description = "Registra um novo movimento no sistema",
            tags = {"Movimento"},
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados do movimento que será registrado",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = MovimentoReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "201",
                            description = "Movimento registrado com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = MovimentoResDTO.class)
                            )
                    )
            }
    )
    @PostMapping("")
    public ResponseEntity<MovimentoResDTO> save (@RequestBody MovimentoReqDTO movimento) {
        return new ResponseEntity<MovimentoResDTO>(movimentoService.save(movimento), HttpStatus.CREATED);
    }
}

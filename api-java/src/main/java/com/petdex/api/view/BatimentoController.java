package com.petdex.api.view;

import com.petdex.api.application.services.batimento.IBatimentoService;
import com.petdex.api.domain.contracts.dto.batimento.BatimentoReqDTO;
import com.petdex.api.domain.contracts.dto.batimento.BatimentoResDTO;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.swagger.respostas.ExemploRespostaPageBatimento;
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
@RequestMapping("/batimentos")
@Tag(name = "Batimentos", description = "Operações de gestão de batimentos cardíacos do animal")
public class BatimentoController {


    @Autowired
    private IBatimentoService batimentoService;

    @Operation(
            summary = "Consultar batimento cardíaco",
            description = "Consulta os detalhes de um registro de batimento cardíaco específico através do seu identificador único",
            tags = {"Batimentos"},
            parameters = {
                    @Parameter(name = "idBatimento", description = "Código identificador do batimento cardíaco que será consultado", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = BatimentoResDTO.class)
                            )
                    )
            }
    )
    @GetMapping("/{idBatimento}")
    public ResponseEntity<BatimentoResDTO> findById(@PathVariable String idBatimento) {
        return new ResponseEntity<>(
                batimentoService.fidById(idBatimento), HttpStatus.OK
        );
    }


    @Operation(
            summary = "Consultar batimentos cardíacos do animal",
            description = "Consulta uma lista paginada de todos os batimentos cardíacos registrados para um animal específico. " +
                         "Os resultados são ordenados por data de coleta (mais recentes primeiro) por padrão.",
            tags = {"Batimentos"},
            parameters = {
                    @Parameter(name = "idAnimal", description = "Código identificador do animal que terá os batimentos consultados", required = true, example = "507f1f77bcf86cd799439011"),
                    @Parameter(name = "page", description = "Número da página que será feita a requisição", example = "0", schema = @Schema(implementation = Integer.class)),
                    @Parameter(name = "size", description = "Quantidade máxima de elementos por página", example = "10", schema = @Schema(implementation = Integer.class)),
                    @Parameter(
                            name = "sortBy",
                            description = "Atributo pelo qual os resultados serão ordenados.\n\n" +
                                    "**Atributos disponíveis**\n" +
                                    "- **data**: Data e hora da coleta\n" +
                                    "- **frequenciaMedia**: Frequência cardíaca média",
                            example = "data",
                            schema = @Schema(implementation = String.class)
                    ),
                    @Parameter(
                            name = "direction",
                            description = "Direção da ordenação.\n\n" +
                                    "**Valores disponíveis**\n" +
                                    "- **asc**: Ordena de forma ascendente\n" +
                                    "- **desc**: Ordena de forma descendente",
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
                                    schema = @Schema(implementation = ExemploRespostaPageBatimento.class)
                            )
                    )
            }
    )
    @GetMapping("/animal/{idAnimal}")
    public ResponseEntity<Page<BatimentoResDTO>> findAllByAnimal(@PathVariable String idAnimal, @ParameterObject @ModelAttribute PageDTO pageDTO) {
        return new ResponseEntity<>(batimentoService.findAllByAnimalId(idAnimal, pageDTO),
            HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar batimentos cardíacos da coleira",
            description = "Consulta uma lista paginada de todos os batimentos cardíacos registrados por uma coleira específica. " +
                         "Os resultados são ordenados por data de coleta (mais recentes primeiro) por padrão.",
            tags = {"Batimentos"},
            parameters = {
                    @Parameter(name = "idColeira", description = "Código identificador da coleira que terá os batimentos consultados", required = true, example = "507f1f77bcf86cd799439011"),
                    @Parameter(name = "page", description = "Número da página que será feita a requisição", example = "0", schema = @Schema(implementation = Integer.class)),
                    @Parameter(name = "size", description = "Quantidade máxima de elementos por página", example = "10", schema = @Schema(implementation = Integer.class)),
                    @Parameter(
                            name = "sortBy",
                            description = "Atributo pelo qual os resultados serão ordenados.\n\n" +
                                    "**Atributos disponíveis**\n" +
                                    "- **data**: Data e hora da coleta\n" +
                                    "- **frequenciaMedia**: Frequência cardíaca média",
                            example = "data",
                            schema = @Schema(implementation = String.class)
                    ),
                    @Parameter(
                            name = "direction",
                            description = "Direção da ordenação.\n\n" +
                                    "**Valores disponíveis**\n" +
                                    "- **asc**: Ordena de forma ascendente\n" +
                                    "- **desc**: Ordena de forma descendente",
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
                                    schema = @Schema(implementation = ExemploRespostaPageBatimento.class)
                            )
                    )
            }
    )
    @GetMapping("/coleira/{idColeira}")
    public ResponseEntity<Page<BatimentoResDTO>> findAllByColeira(@PathVariable String idColeira, @ParameterObject @ModelAttribute PageDTO pageDTO) {
        return new ResponseEntity<>(
                batimentoService.findAllByColeiraId(idColeira, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar último batimento cardíaco do animal",
            description = "Consulta o batimento cardíaco mais recente registrado de um animal específico, ordenado por data de coleta",
            tags = {"Batimentos"},
            parameters = {
                    @Parameter(name = "idAnimal", description = "Código identificador do animal que terá o último batimento consultado", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = BatimentoResDTO.class)
                            )
                    )
            }
    )
    @GetMapping("/animal/{idAnimal}/ultimo")
    public ResponseEntity<BatimentoResDTO> findLastByAnimal(@PathVariable String idAnimal) {
        return batimentoService.findLastByAnimalId(idAnimal)
                .map(batimento -> new ResponseEntity<>(batimento, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @Operation(
            summary = "Registrar batimento cardíaco",
            description = "Registra um novo batimento cardíaco no sistema. É necessário informar a data/hora da coleta, " +
                         "a frequência cardíaca média, o ID do animal e o ID da coleira que realizou a medição.",
            tags = {"Batimentos"},
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados do batimento cardíaco que será registrado no sistema",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = BatimentoReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "201",
                            description = "Batimento cardíaco registrado com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = BatimentoResDTO.class)
                            )
                    )
            }
    )
    @PostMapping("")
    public ResponseEntity<BatimentoResDTO> save (@RequestBody BatimentoReqDTO batimento) {
        return new ResponseEntity<BatimentoResDTO>(batimentoService.save(batimento), HttpStatus.CREATED);
    }

}

package com.petdex.api.view;

import com.petdex.api.application.services.localizacao.ILocalizacaoService;
import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoReqDTO;
import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoResDTO;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.swagger.respostas.ExemploRespostaPageLocalizacao;
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
            summary = "Consultar localização",
            description = "Consulta os detalhes de um registro de localização específico através do seu identificador único",
            tags = {"Localizacao"},
            parameters = {
                    @Parameter(name = "idLocalizacao", description = "Código identificador da localização que será consultada", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = LocalizacaoResDTO.class)
                            )
                    )
            }
    )
    @GetMapping("/{idLocalizacao}")
    public ResponseEntity<LocalizacaoResDTO> findById(@PathVariable String idLocalizacao) {
        return new ResponseEntity<>(
                localizacaoService.fidById(idLocalizacao), HttpStatus.OK
        );
    }


    @Operation(
            summary = "Consultar localizações por animal",
            description = "Consulta uma lista paginada de todas as localizações registradas para um animal específico",
            tags = {"Localizacao"},
            parameters = {
                    @Parameter(name = "idAnimal", description = "Código identificador do animal que terá as localizações consultadas", required = true, example = "507f1f77bcf86cd799439011"),
                    @Parameter(name = "page", description = "Número da página que será feita a requisição", example = "0", schema = @Schema(implementation = Integer.class)),
                    @Parameter(name = "size", description = "Quantidade máxima de elementos por página", example = "10", schema = @Schema(implementation = Integer.class)),
                    @Parameter(
                            name = "sortBy",
                            description = "Atributo pelo qual as respostas serão ordenadas.\n\n" +
                                    "**Atributos disponíveis para ordenação**\n" +
                                    "- **data**: Ordena pela data e hora da coleta da localização\n" +
                                    "- **latitude**: Ordena pela latitude da localização\n" +
                                    "- **longitude**: Ordena pela longitude da localização\n" +
                                    "- **id**: Ordena pelo código identificador da localização",
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
                                    schema = @Schema(implementation = ExemploRespostaPageLocalizacao.class)
                            )
                    )
            }
    )
    @GetMapping("/animal/{idAnimal}")
    public ResponseEntity<Page<LocalizacaoResDTO>> findAllByAnimal(@PathVariable String idAnimal, @ParameterObject PageDTO pageDTO) {

        return new ResponseEntity<>(localizacaoService.findAllByAnimalId(idAnimal, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar localizações por coleira",
            description = "Consulta uma lista paginada de todas as localizações registradas por uma coleira específica",
            tags = {"Localizacao"},
            parameters = {
                    @Parameter(name = "idColeira", description = "Código identificador da coleira que terá as localizações consultadas", required = true, example = "507f1f77bcf86cd799439011"),
                    @Parameter(name = "page", description = "Número da página que será feita a requisição", example = "0", schema = @Schema(implementation = Integer.class)),
                    @Parameter(name = "size", description = "Quantidade máxima de elementos por página", example = "10", schema = @Schema(implementation = Integer.class)),
                    @Parameter(
                            name = "sortBy",
                            description = "Atributo pelo qual as respostas serão ordenadas.\n\n" +
                                    "**Atributos disponíveis para ordenação**\n" +
                                    "- **data**: Ordena pela data e hora da coleta da localização\n" +
                                    "- **latitude**: Ordena pela latitude da localização\n" +
                                    "- **longitude**: Ordena pela longitude da localização\n" +
                                    "- **id**: Ordena pelo código identificador da localização",
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
                                    schema = @Schema(implementation = ExemploRespostaPageLocalizacao.class)
                            )
                    )
            }
    )
    @GetMapping("/coleira/{idColeira}")
    public ResponseEntity<Page<LocalizacaoResDTO>> findAllByColeira(@PathVariable String idColeira, @ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                localizacaoService.findAllByColeiraId(idColeira, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar última localização do animal",
            description = "Consulta a localização mais recente registrada de um animal específico",
            tags = {"Localizacao"},
            parameters = {
                    @Parameter(name = "idAnimal", description = "Código identificador do animal que terá a última localização consultada", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = LocalizacaoResDTO.class)
                            )
                    )
            }
    )
    @GetMapping("/animal/{idAnimal}/ultima")
    public ResponseEntity<LocalizacaoResDTO> findLastByAnimal(@PathVariable String idAnimal) {
        return localizacaoService.findLastByAnimalId(idAnimal)
                .map(localizacao -> new ResponseEntity<>(localizacao, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @Operation(
            summary = "Registrar localização",
            description = "Registra uma nova localização no sistema",
            tags = {"Localizacao"},
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados da localização que será registrada",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = LocalizacaoReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "201",
                            description = "Localização registrada com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = LocalizacaoResDTO.class)
                            )
                    )
            }
    )
    @PostMapping("")
    public ResponseEntity<LocalizacaoResDTO> save (@RequestBody LocalizacaoReqDTO localizacao) {
        return new ResponseEntity<LocalizacaoResDTO>(localizacaoService.save(localizacao), HttpStatus.CREATED);
    }
}

package com.petdex.api.view;

import com.petdex.api.application.services.batimento.IBatimentoService;
import com.petdex.api.domain.contracts.dto.batimento.BatimentoReqDTO;
import com.petdex.api.domain.contracts.dto.batimento.BatimentoResDTO;
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
@RequestMapping("/batimentos")
@Tag(name = "Batimentos", description = "Operações de gestão de batimentos cardíacos do animal")
public class BatimentoController {


    @Autowired
    private IBatimentoService batimentoService;

    @Operation(
            summary = "Consultar batimento cardíaco pelo ID",
            description = "Retorna os detalhes de um registro de batimento cardíaco específico através do seu identificador único",
            parameters = {
                    @Parameter(name = "idBatimento", description = "ID do batimento que se deseja consultar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Batimento cardíaco encontrado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = BatimentoResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Batimento cardíaco não encontrado",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/{idBatimento}")
    public ResponseEntity<BatimentoResDTO> findById(@PathVariable String idBatimento) {
        return new ResponseEntity<>(
                batimentoService.fidById(idBatimento), HttpStatus.OK
        );
    }


    @Operation(
            summary = "Consultar batimentos cardíacos pelo ID do animal",
            description = "Retorna uma lista paginada de todos os batimentos cardíacos registrados para um animal específico",
            parameters = {
                    @Parameter(name = "idAnimal", description = "ID do animal que se deseja consultar os batimentos", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de batimentos cardíacos retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/animal/{idAnimal}")
    public ResponseEntity<Page<BatimentoResDTO>> findAllByAnimal(@PathVariable String idAnimal, @ParameterObject @ModelAttribute PageDTO pageDTO) {
        return new ResponseEntity<>(batimentoService.findAllByAnimalId(idAnimal, pageDTO),
            HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar batimentos cardíacos pelo ID da coleira",
            description = "Retorna uma lista paginada de todos os batimentos cardíacos registrados por uma coleira específica",
            parameters = {
                    @Parameter(name = "idColeira", description = "ID da coleira que se deseja consultar os batimentos cardíacos", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de batimentos cardíacos retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/coleira/{idColeira}")
    public ResponseEntity<Page<BatimentoResDTO>> findAllByColeira(@PathVariable String idColeira, @ParameterObject @ModelAttribute PageDTO pageDTO) {
        return new ResponseEntity<>(
                batimentoService.findAllByColeiraId(idColeira, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Buscar o último batimento cardíaco registrado de um animal",
            description = "Retorna o batimento cardíaco mais recente de um animal específico, ordenado por data de registro",
            parameters = {
                    @Parameter(name = "idAnimal", description = "ID do animal que se deseja consultar o último batimento", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Último batimento cardíaco encontrado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = BatimentoResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Nenhum batimento cardíaco encontrado para o animal",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/animal/{idAnimal}/ultimo")
    public ResponseEntity<BatimentoResDTO> findLastByAnimal(@PathVariable String idAnimal) {
        return batimentoService.findLastByAnimalId(idAnimal)
                .map(batimento -> new ResponseEntity<>(batimento, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @Operation(
            summary = "Registrar um novo batimento cardíaco",
            description = "Cria um novo registro de batimento cardíaco no sistema. É necessário informar o ID do animal ou coleira e o valor do batimento."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Batimento cardíaco registrado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = BatimentoResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PostMapping("")
    public ResponseEntity<BatimentoResDTO> save (@RequestBody BatimentoReqDTO batimento) {
        return new ResponseEntity<BatimentoResDTO>(batimentoService.save(batimento), HttpStatus.CREATED);
    }

}

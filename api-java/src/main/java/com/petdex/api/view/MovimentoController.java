package com.petdex.api.view;

import com.petdex.api.application.services.movimento.IMovimentoService;
import com.petdex.api.domain.contracts.dto.movimento.MovimentoReqDTO;
import com.petdex.api.domain.contracts.dto.movimento.MovimentoResDTO;
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
@Tag(name = "Movimento", description = "Operações de gestão de movimentos dos animais")
@RequestMapping("/movimentos")
public class MovimentoController {
    @Autowired
    private IMovimentoService movimentoService;

    @Operation(
            summary = "Consultar movimento pelo ID",
            description = "Retorna os detalhes de um registro de movimento específico através do seu identificador único",
            parameters = {
                    @Parameter(name = "idMovimento", description = "ID do movimento que se deseja consultar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Movimento encontrado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = MovimentoResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Movimento não encontrado",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/{idMovimento}")
    public ResponseEntity<MovimentoResDTO> findById(@PathVariable String idMovimento) {
        return new ResponseEntity<>(
                movimentoService.fidById(idMovimento), HttpStatus.OK
        );
    }


    @Operation(
            summary = "Consultar movimentos pelo ID do animal",
            description = "Retorna uma lista paginada de todos os movimentos registrados para um animal específico",
            parameters = {
                    @Parameter(name = "idAnimal", description = "ID do animal que se deseja consultar os movimentos", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de movimentos retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/animal/{idAnimal}")
    public ResponseEntity<Page<MovimentoResDTO>> findAllByAnimal(@PathVariable String idAnimal, @ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(movimentoService.findAllByAnimalId(idAnimal, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar movimentos pelo ID da coleira",
            description = "Retorna uma lista paginada de todos os movimentos registrados por uma coleira específica",
            parameters = {
                    @Parameter(name = "idColeira", description = "ID da coleira que se deseja consultar os movimentos", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de movimentos retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/coleira/{idColeira}")
    public ResponseEntity<Page<MovimentoResDTO>> findAllByColeira(@PathVariable String idColeira, @ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                movimentoService.findAllByColeiraId(idColeira, pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Registrar um novo movimento",
            description = "Cria um novo registro de movimento no sistema. É necessário informar o ID do animal ou coleira e os dados do movimento."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Movimento registrado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = MovimentoResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PostMapping("")
    public ResponseEntity<MovimentoResDTO> save (@RequestBody MovimentoReqDTO movimento) {
        return new ResponseEntity<MovimentoResDTO>(movimentoService.save(movimento), HttpStatus.CREATED);
    }
}

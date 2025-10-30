package com.petdex.api.view;

import com.petdex.api.application.services.animal.IAnimalService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.animal.AnimalReqDTO;
import com.petdex.api.domain.contracts.dto.animal.AnimalResDTO;
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
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Date;
import java.util.Optional;

@RestController
@RequestMapping("/animais")
@Tag(name = "Animal", description = "Operações de gestão envolvendo animais")
public class AnimalController {

    @Autowired
    IAnimalService animalService;

    @Operation(
            summary = "Buscar animal por ID",
            description = "Retorna os detalhes de um animal específico através do seu identificador único",
            parameters = {
                    @Parameter(name = "id", description = "ID do animal que se deseja consultar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Animal encontrado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = AnimalResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Animal não encontrado",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<AnimalResDTO> findById (@PathVariable String id) {
        return new ResponseEntity<>(
                animalService.findById(id),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Listar todos os animais",
            description = "Retorna uma lista paginada de todos os animais cadastrados no sistema. " +
                    "É possível ordenar e filtrar os resultados através dos parâmetros de paginação."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de animais retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<AnimalResDTO>> findAll (@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                animalService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Buscar animal pelo ID do usuário",
            description = "Retorna o animal associado a um usuário específico através do ID do usuário",
            parameters = {
                    @Parameter(name = "usuarioId", description = "ID do usuário que se deseja consultar o animal", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Animal encontrado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = AnimalResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Animal não encontrado para o usuário informado",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<AnimalResDTO> findByUsuarioId(@PathVariable String usuarioId) {
        Optional<AnimalResDTO> animal = animalService.findByUsuarioId(usuarioId);
        return animal
                .map(a -> new ResponseEntity<>(a, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @Operation(
            summary = "Cadastrar um animal",
            description = "Cria um novo animal no sistema. É necessário informar todos os dados do animal incluindo nome, raça, espécie e usuário responsável."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Animal criado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = AnimalResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PostMapping(consumes = "multipart/form-data")
    public ResponseEntity<AnimalResDTO> create(
           @RequestBody AnimalReqDTO animalDTO) throws IOException {

       return new ResponseEntity<>(
                animalService.create(animalDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Atualizar o cadastro de um animal",
            description = "Atualiza as informações de um animal existente no sistema através do seu ID",
            parameters = {
                    @Parameter(name = "id", description = "ID do animal que se deseja atualizar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Animal atualizado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = AnimalResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "404", description = "Animal não encontrado",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PutMapping(value = "/{id}", consumes = "multipart/form-data")
    public ResponseEntity<AnimalResDTO> update(
            @PathVariable String id,
            @RequestBody AnimalReqDTO animalDTO
) throws IOException {
        return new ResponseEntity<>(
                animalService.update(id, animalDTO),
                HttpStatus.OK
        );
    }

    @PostMapping(value = "/{id}/imagem", consumes = "multipart/form-data")
    public ResponseEntity<String> saveImagem(@PathVariable String id, @RequestParam(required = false) MultipartFile imagem) throws IOException {
        return new ResponseEntity<>(
                animalService.saveImage(id, imagem),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Deletar um animal",
            description = "Remove um animal do sistema através do seu ID",
            parameters = {
                    @Parameter(name = "id", description = "ID do animal que se deseja deletar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Animal deletado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = String.class))),
            @ApiResponse(responseCode = "404", description = "Animal não encontrado",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete (@PathVariable String id) {
        animalService.delete(id);
        return new ResponseEntity<>("Animal deletado",HttpStatus.OK);
    }
}

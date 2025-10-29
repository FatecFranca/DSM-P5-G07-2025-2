package com.petdex.api.view;

import com.petdex.api.application.services.usuario.IUsuarioService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.usuario.UsuarioReqDTO;
import com.petdex.api.domain.contracts.dto.usuario.UsuarioResDTO;
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
@RequestMapping("usuarios")
@Tag(name = "Usuário", description = "Operações de gestão envolvendo usuários")
public class UsuarioController {

    @Autowired
    IUsuarioService usuarioService;

    @Operation(
            summary = "Buscar usuário por ID",
            description = "Retorna os detalhes de um usuário específico através do seu identificador único",
            parameters = {
                    @Parameter(name = "id", description = "ID do usuário que se deseja consultar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuário encontrado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResDTO.class))),
            @ApiResponse(responseCode = "404", description = "Usuário não encontrado",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<UsuarioResDTO> findById (@PathVariable String id) {
        return new ResponseEntity<>(
                usuarioService.findById(id),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Listar todos os usuários",
            description = "Retorna uma lista paginada de todos os usuários cadastrados no sistema. " +
                    "É possível ordenar e filtrar os resultados através dos parâmetros de paginação."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista de usuários retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = Page.class))),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @GetMapping()
    public ResponseEntity<Page<UsuarioResDTO>> findAll (@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                usuarioService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Cadastrar um novo usuário",
            description = "Cria um novo usuário no sistema. É necessário informar nome, email, senha e outros dados pessoais."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Usuário criado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PostMapping("")
    public ResponseEntity<UsuarioResDTO> create (@RequestBody UsuarioReqDTO usuarioReqDTO) {
        return new ResponseEntity<>(
                usuarioService.create(usuarioReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Atualizar o cadastro de um usuário",
            description = "Atualiza as informações de um usuário existente no sistema através do seu ID",
            parameters = {
                    @Parameter(name = "id", description = "ID do usuário que se deseja atualizar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuário atualizado com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResDTO.class))),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "404", description = "Usuário não encontrado",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<UsuarioResDTO> update (@PathVariable String id, @RequestBody UsuarioReqDTO usuarioReqDTO){
        return new ResponseEntity<>(
                usuarioService.update(id, usuarioReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Deletar um usuário",
            description = "Remove um usuário do sistema através do seu ID",
            parameters = {
                    @Parameter(name = "id", description = "ID do usuário que se deseja deletar", required = true, example = "507f1f77bcf86cd799439011")
            }
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuário deletado com sucesso",
                    content = @Content),
            @ApiResponse(responseCode = "404", description = "Usuário não encontrado",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity delete (@PathVariable String id) {
        usuarioService.delete(id);
        return new ResponseEntity(HttpStatus.OK);
    }
}

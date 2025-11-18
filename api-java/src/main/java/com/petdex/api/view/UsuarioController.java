package com.petdex.api.view;

import com.petdex.api.application.services.usuario.IUsuarioService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.usuario.UsuarioReqDTO;
import com.petdex.api.domain.contracts.dto.usuario.UsuarioResDTO;
import com.petdex.api.swagger.respostas.ExemploRespostaDeletarUsuario;
import com.petdex.api.swagger.respostas.ExemploRespostaPageUsuario;
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
            summary = "Consultar usuário",
            description = "Consulta os detalhes de um usuário específico através do seu identificador único",
            tags = {"Usuario"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador do usuário que será consultado", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Solicitação bem-sucedida",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = UsuarioResDTO.class)
                            )
                    )
            }
    )
    @GetMapping("/{id}")
    public ResponseEntity<UsuarioResDTO> findById (@PathVariable String id) {
        return new ResponseEntity<>(
                usuarioService.findById(id),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Consultar usuários",
            description = "Consulta uma lista paginada de todos os usuários cadastrados no sistema",
            tags = {"Usuario"},
            parameters = {
                    @Parameter(name = "page", description = "Número da página que será feita a requisição", example = "0", schema = @Schema(implementation = Integer.class)),
                    @Parameter(name = "size", description = "Quantidade máxima de elementos por página", example = "10", schema = @Schema(implementation = Integer.class)),
                    @Parameter(
                            name = "sortBy",
                            description = "Atributo pelo qual as respostas serão ordenadas.\n\n" +
                                    "**Atributos disponíveis para ordenação**\n" +
                                    "- **nome**: Ordena pelo nome do usuário\n" +
                                    "- **email**: Ordena pelo email do usuário\n" +
                                    "- **cpf**: Ordena pelo CPF do usuário\n" +
                                    "- **id**: Ordena pelo código identificador do usuário",
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
                                    schema = @Schema(implementation = ExemploRespostaPageUsuario.class)
                            )
                    )
            }
    )
    @GetMapping()
    public ResponseEntity<Page<UsuarioResDTO>> findAll (@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                usuarioService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Cadastrar usuário",
            description = "Cadastra um novo usuário no sistema",
            tags = {"Usuario"},
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados do usuário que será cadastrado",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = UsuarioReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "201",
                            description = "Usuário cadastrado com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = UsuarioResDTO.class)
                            )
                    )
            }
    )
    @PostMapping("")
    public ResponseEntity<UsuarioResDTO> create (@RequestBody UsuarioReqDTO usuarioReqDTO) {
        return new ResponseEntity<>(
                usuarioService.create(usuarioReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(
            summary = "Atualizar usuário",
            description = "Atualiza as informações de um usuário existente no sistema",
            tags = {"Usuario"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador do usuário que será atualizado", required = true, example = "507f1f77bcf86cd799439011")
            },
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados atualizados do usuário",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = UsuarioReqDTO.class)
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Usuário atualizado com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = UsuarioResDTO.class)
                            )
                    )
            }
    )
    @PutMapping("/{id}")
    public ResponseEntity<UsuarioResDTO> update (@PathVariable String id, @RequestBody UsuarioReqDTO usuarioReqDTO){
        return new ResponseEntity<>(
                usuarioService.update(id, usuarioReqDTO),
                HttpStatus.OK
        );
    }

    @Operation(
            summary = "Deletar usuário",
            description = "Remove um usuário do sistema",
            tags = {"Usuario"},
            parameters = {
                    @Parameter(name = "id", description = "Código identificador do usuário que será deletado", required = true, example = "507f1f77bcf86cd799439011")
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Usuário deletado com sucesso",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = ExemploRespostaDeletarUsuario.class)
                            )
                    )
            }
    )
    @DeleteMapping("/{id}")
    public ResponseEntity delete (@PathVariable String id) {
        usuarioService.delete(id);
        return new ResponseEntity(HttpStatus.OK);
    }
}

package com.petdex.api.view;

import com.petdex.api.application.services.usuario.IUsuarioService;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.usuario.UsuarioReqDTO;
import com.petdex.api.domain.contracts.dto.usuario.UsuarioResDTO;
import io.swagger.v3.oas.annotations.Operation;
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

    @GetMapping("/{id}")
    public ResponseEntity<UsuarioResDTO> findById (@PathVariable String id) {
        return new ResponseEntity<>(
                usuarioService.findById(id),
                HttpStatus.OK
        );
    }

    @GetMapping()
    public ResponseEntity<Page<UsuarioResDTO>> findAll (@ParameterObject PageDTO pageDTO) {
        return new ResponseEntity<>(
                usuarioService.findAll(pageDTO),
                HttpStatus.OK
        );
    }

    @Operation(summary = "Cadastrar um novo usuário")
    @PostMapping("")
    public ResponseEntity<UsuarioResDTO> create (@RequestBody UsuarioReqDTO usuarioReqDTO) {
        return new ResponseEntity<>(
                usuarioService.create(usuarioReqDTO),
                HttpStatus.CREATED
        );
    }

    @Operation(summary = "Atualizar o cadastro de um usuário")
    @PutMapping("/{id}")
    public ResponseEntity<UsuarioResDTO> update (@PathVariable String id, @RequestBody UsuarioReqDTO usuarioReqDTO){
        return new ResponseEntity<>(
                usuarioService.update(id, usuarioReqDTO),
                HttpStatus.CREATED
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity delete (@PathVariable String id) {
        usuarioService.delete(id);
        return new ResponseEntity(HttpStatus.OK);
    }
}

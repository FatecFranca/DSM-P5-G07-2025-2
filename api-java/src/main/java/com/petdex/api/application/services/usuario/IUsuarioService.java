package com.petdex.api.application.services.usuario;

import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.usuario.UsuarioReqDTO;
import com.petdex.api.domain.contracts.dto.usuario.UsuarioResDTO;
import org.springframework.data.domain.Page;

public interface IUsuarioService {

    UsuarioResDTO findById(String id);
    Page<UsuarioResDTO> findAll(PageDTO pageDTO);
    UsuarioResDTO create (UsuarioReqDTO usuarioDTO);
    UsuarioResDTO update (String id, UsuarioReqDTO usuarioReqDTO);
    void delete (String id);

}

package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Usuario;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface UsuarioRepository extends MongoRepository<Usuario, String> {

    /**
     * Busca um usuário pelo email
     * @param email Email do usuário
     * @return Optional contendo o usuário se encontrado
     */
    Optional<Usuario> findByEmail(String email);
}

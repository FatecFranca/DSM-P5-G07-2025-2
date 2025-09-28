package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Usuario;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface UsuarioRepository extends MongoRepository<Usuario, String> {
}

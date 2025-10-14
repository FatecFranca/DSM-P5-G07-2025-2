package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Animal;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface AnimalRepository extends MongoRepository<Animal, String> {

    /**
     * Busca o primeiro animal vinculado a um usuário
     * @param usuario ID do usuário
     * @return Optional contendo o animal se encontrado
     */
    Optional<Animal> findFirstByUsuario(String usuario);
}

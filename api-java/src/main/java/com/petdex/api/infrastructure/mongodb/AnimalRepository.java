package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Animal;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.util.Optional;

public interface AnimalRepository extends MongoRepository<Animal, String> {

    /**
     * Busca o animal vinculado a um usuário
     * @param usuario ID do usuário (será convertido automaticamente para ObjectId)
     * @return Optional contendo o animal se encontrado
     */
    @Query("{ 'usuario' : ?#{[0]} }")
    Optional<Animal> findByUsuario(ObjectId usuario);
}

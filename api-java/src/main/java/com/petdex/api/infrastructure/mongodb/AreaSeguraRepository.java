package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.AreaSegura;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositório para operações de banco de dados relacionadas a áreas seguras
 */
@Repository
public interface AreaSeguraRepository extends MongoRepository<AreaSegura, String> {
    
    /**
     * Busca a área segura configurada para um animal específico
     * @param animal ID do animal
     * @return Optional contendo a área segura se existir
     */
    Optional<AreaSegura> findByAnimal(String animal);
    
    /**
     * Verifica se existe uma área segura configurada para um animal
     * @param animal ID do animal
     * @return true se existir, false caso contrário
     */
    boolean existsByAnimal(String animal);
    
    /**
     * Deleta a área segura de um animal específico
     * @param animal ID do animal
     */
    void deleteByAnimal(String animal);
}


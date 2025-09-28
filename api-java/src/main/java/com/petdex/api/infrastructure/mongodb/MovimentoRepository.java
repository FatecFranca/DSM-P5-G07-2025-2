package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Movimento;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface MovimentoRepository extends MongoRepository<Movimento, String> {
    Page<Movimento> findAllByAnimal(String animalId, Pageable pageable);
    Page<Movimento> findAllByColeira(String coleiraId, Pageable pageable);
}

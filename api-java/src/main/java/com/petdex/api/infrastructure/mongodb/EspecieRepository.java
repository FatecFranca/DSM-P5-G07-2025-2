package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Especie;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface EspecieRepository extends MongoRepository<Especie, String> {
}

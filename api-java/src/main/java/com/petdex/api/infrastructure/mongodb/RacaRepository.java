package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Raca;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface RacaRepository extends MongoRepository<Raca, String> {
}

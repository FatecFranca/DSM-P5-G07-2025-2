package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Animal;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface AnimalRepository extends MongoRepository<Animal, String> {


}

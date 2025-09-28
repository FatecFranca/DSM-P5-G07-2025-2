package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Coleira;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ColeiraRepository extends MongoRepository<Coleira, String> {

}

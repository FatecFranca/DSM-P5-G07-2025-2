package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Batimento;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BatimentoRepository extends MongoRepository<Batimento, String> {

    Page<Batimento> findAllByAnimal(String animal, Pageable pageable);
    Page<Batimento> findAllByColeira(String coleira, Pageable pageable);
}

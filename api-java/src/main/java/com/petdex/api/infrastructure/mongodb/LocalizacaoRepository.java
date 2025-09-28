package com.petdex.api.infrastructure.mongodb;

import com.petdex.api.domain.collections.Localizacao;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface LocalizacaoRepository extends MongoRepository<Localizacao, String> {
    Page<Localizacao> findAllByAnimal(String animal, Pageable pageable);
    Page<Localizacao> findAllByColeira(String coleira, Pageable pageable);
}

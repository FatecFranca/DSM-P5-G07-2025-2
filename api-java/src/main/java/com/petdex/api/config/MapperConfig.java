package com.petdex.api.config;

import com.petdex.api.domain.collections.Batimento;
import com.petdex.api.domain.collections.Localizacao;
import com.petdex.api.domain.collections.Movimento;
import com.petdex.api.domain.contracts.dto.batimento.BatimentoReqDTO;
import com.petdex.api.domain.contracts.dto.localizacao.LocalizacaoReqDTO;
import com.petdex.api.domain.contracts.dto.movimento.MovimentoReqDTO;
import org.modelmapper.ModelMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MapperConfig {

    @Bean
    public ModelMapper modelMapper() {

        ModelMapper mapper = new ModelMapper();

        mapper.getConfiguration()
                .setAmbiguityIgnored(true);

        mapper.createTypeMap(BatimentoReqDTO.class, Batimento.class)
                .addMappings(m -> m.skip(Batimento::setId));

        mapper.createTypeMap(MovimentoReqDTO.class, Movimento.class)
                .addMappings(m -> m.skip(Movimento::setId));


        mapper.createTypeMap(LocalizacaoReqDTO.class, Localizacao.class)
                .addMappings(m -> m.skip(Localizacao::setId));


        return  mapper;
    }
}

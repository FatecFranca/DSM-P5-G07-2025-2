package com.petdex.api.application.services.movimento;

import com.petdex.api.application.services.ValidationService;
import com.petdex.api.domain.collections.Movimento;
import com.petdex.api.domain.contracts.dto.movimento.MovimentoReqDTO;
import com.petdex.api.domain.contracts.dto.movimento.MovimentoResDTO;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.infrastructure.mongodb.MovimentoRepository;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MovimentoService implements IMovimentoService {


    @Autowired
    private MovimentoRepository movimentoRepository;

    @Autowired
    private ModelMapper mapper;

    @Autowired
    private ValidationService validation;

    @Override
    public MovimentoResDTO save(MovimentoReqDTO movimentoReq) {

//        if (!validation.existAnimal(movimentoReq.getAnimalId()) || !validation.existColeira(movimentoReq.getColeiraId())) {
//            return null; // Lançar excessão 404
//        }

        return mapper.map(movimentoRepository.save(mapper.map(movimentoReq, Movimento.class)), MovimentoResDTO.class);
    }

    @Override
    public MovimentoResDTO fidById(String movimentoId) {

        return mapper.map(movimentoRepository.findById(movimentoId), MovimentoResDTO.class);
    }

    @Override
    public Page<MovimentoResDTO> findAllByAnimalId(String animalId, PageDTO pageDTO) {
        pageDTO.sortByNewest();
        Page<Movimento> batimentosPage = movimentoRepository.findAllByAnimal(animalId, pageDTO.mapPage());

        List<MovimentoResDTO> dtoList = batimentosPage.getContent().stream()
                .map(b -> mapper.map(b, MovimentoResDTO.class))
                .toList();

        return new PageImpl<MovimentoResDTO>(dtoList, pageDTO.mapPage(), batimentosPage.getTotalElements());
    }

    @Override
    public Page<MovimentoResDTO> findAllByColeiraId(String coleiraId, PageDTO pageDTO) {
        pageDTO.sortByNewest();
        Page<Movimento> batimentosPage = movimentoRepository.findAllByColeira(coleiraId, pageDTO.mapPage());

        List<MovimentoResDTO> dtoList = batimentosPage.getContent().stream()
                .map(b -> mapper.map(b, MovimentoResDTO.class))
                .toList();

        return new PageImpl<MovimentoResDTO>(dtoList, pageDTO.mapPage(), batimentosPage.getTotalElements());
    }
}

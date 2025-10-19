package com.petdex.api.application.services.auth;

import com.petdex.api.application.services.security.JwtService;
import com.petdex.api.application.services.security.PasswordService;
import com.petdex.api.domain.collections.Animal;
import com.petdex.api.domain.collections.Usuario;
import com.petdex.api.domain.contracts.dto.auth.LoginReqDTO;
import com.petdex.api.domain.contracts.dto.auth.LoginResDTO;
import com.petdex.api.infrastructure.mongodb.AnimalRepository;
import com.petdex.api.infrastructure.mongodb.UsuarioRepository;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Serviço de autenticação responsável pelo login de usuários
 */
@Service
public class AuthService implements IAuthService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private AnimalRepository animalRepository;

    @Autowired
    private PasswordService passwordService;

    @Autowired
    private JwtService jwtService;

    /**
     * Realiza o login do usuário validando as credenciais e gerando um token JWT
     * @param loginReqDTO Dados de login (email e senha)
     * @return Dados de resposta do login (token JWT, ID do animal e informações do usuário)
     * @throws RuntimeException se as credenciais forem inválidas
     */
    @Override
    public LoginResDTO login(LoginReqDTO loginReqDTO) {
        // Busca o usuário pelo email
        Usuario usuario = usuarioRepository.findByEmail(loginReqDTO.getEmail())
                .orElseThrow(() -> new RuntimeException("Credenciais inválidas"));

        // Valida a senha

        if (!passwordService.validatePassword(loginReqDTO.getSenha(), usuario.getSenha())) {
            throw new RuntimeException("Credenciais inválidas");
        }

        // Gera o token JWT
        String token = jwtService.generateToken(usuario.getId(), usuario.getEmail());

        // Busca o animal vinculado ao usuário (se existir)
        // Converte String para ObjectId
        ObjectId usuarioObjectId = new ObjectId(usuario.getId());
        Optional<Animal> animalOpt = animalRepository.findByUsuario(usuarioObjectId);
        String animalId = animalOpt.map(Animal::getId).orElse(null);
        String petName = animalOpt.map(Animal::getNome).orElse(null);

        // Cria e retorna a resposta do login
        return new LoginResDTO(
                token,
                animalId,
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                petName
        );
    }
}


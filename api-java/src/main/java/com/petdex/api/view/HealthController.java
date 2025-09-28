package com.petdex.api.view;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return new ResponseEntity<>("API Java online!", HttpStatus.OK);
    }

    @GetMapping(value = {"", "/"})
    public ResponseEntity<String> api() {
        return new ResponseEntity<>("Seja bem-vindo a API do PetDex! Para acessar a documentação acesse a rota <a href=\"/swagger\">/swagger</a>", HttpStatus.OK);
    }
}

package com.petdex.api.infrastructure.exception;

/**
 * Exceção lançada quando a requisição contém dados inválidos
 * Deve retornar HTTP 400 (Bad Request)
 */
public class BadRequestException extends RuntimeException {
    
    public BadRequestException(String message) {
        super(message);
    }
}


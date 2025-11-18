package com.petdex.api.infrastructure.exception;

/**
 * Exceção lançada quando há conflito de dados (ex: email ou CPF duplicado)
 * Deve retornar HTTP 409 (Conflict)
 */
public class ConflictException extends RuntimeException {
    
    public ConflictException(String message) {
        super(message);
    }
    
    public ConflictException(String resourceName, String fieldName, Object fieldValue) {
        super(String.format("%s já cadastrado(a) com %s: '%s'", resourceName, fieldName, fieldValue));
    }
}


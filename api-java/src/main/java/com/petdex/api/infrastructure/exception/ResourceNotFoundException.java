package com.petdex.api.infrastructure.exception;

/**
 * Exceção lançada quando um recurso não é encontrado
 * Deve retornar HTTP 404 (Not Found)
 */
public class ResourceNotFoundException extends RuntimeException {
    
    public ResourceNotFoundException(String message) {
        super(message);
    }
    
    public ResourceNotFoundException(String resourceName, String fieldName, Object fieldValue) {
        super(String.format("%s não encontrado(a) com %s: '%s'", resourceName, fieldName, fieldValue));
    }
}


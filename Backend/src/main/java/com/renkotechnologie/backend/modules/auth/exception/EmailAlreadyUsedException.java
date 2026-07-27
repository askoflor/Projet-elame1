package com.renkotechnologie.backend.modules.auth.exception;

public class EmailAlreadyUsedException extends RuntimeException {
    public EmailAlreadyUsedException(String email) {
        super("Un compte existe deja avec l'email " + email);
    }
}

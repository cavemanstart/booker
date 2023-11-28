package com.booker.utils.response.exception;

public class TokenInvalidException extends RuntimeException {

    public TokenInvalidException() {}

    public TokenInvalidException(String message) {
        super(message);
    }

}

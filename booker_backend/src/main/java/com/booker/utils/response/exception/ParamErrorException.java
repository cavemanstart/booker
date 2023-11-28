package com.booker.utils.response.exception;

public class ParamErrorException extends RuntimeException {

    public ParamErrorException() {}

    public ParamErrorException(String message) {
        super(message);
    }

}

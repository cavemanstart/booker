package com.booker.utils.response.exception;

public class ResourcesNotFoundException extends RuntimeException {

    public ResourcesNotFoundException() {}

    public ResourcesNotFoundException(String message) {
        super(message);
    }

}

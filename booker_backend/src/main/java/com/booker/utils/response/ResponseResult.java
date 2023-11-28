package com.booker.utils.response;

import lombok.Data;

@Data
public class ResponseResult {

    private Integer code;
    private String message;

    public ResponseResult() {}

    public ResponseResult(MyResponseStatus resultEnum) {
        this.code = resultEnum.getCode();
        this.message = resultEnum.getMessage();
    }

    public ResponseResult(Integer code, String message) {
        this.code = code;
        this.message = message;
    }

}

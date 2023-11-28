package com.booker.utils.response;

public enum MyResponseStatus {

    SUCCESS(200, "请求成功"),
    CREATED(201, "创建成功"),
    DELETED(204, "删除成功"),
    PARAM_NOT_PRESENT(400, "缺少请求参数"),
    TOKEN_INVALID(401, "Token失效"),
    FORBIDDEN(403, "请求错误"),
    NOT_FOUNT(404, "请求资源不存在"),
    PARAM_FORMAT_ERROR(412, "数据格式错误");

    private final Integer code;
    private final String message;

    MyResponseStatus(Integer code, String message) {
        this.code = code;
        this.message = message;
    }

    public Integer getCode() {
        return this.code;
    }

    public String getMessage() {
        return this.message;
    }

}

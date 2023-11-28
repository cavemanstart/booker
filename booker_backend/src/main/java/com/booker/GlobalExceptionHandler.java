package com.booker;

import com.booker.utils.response.ResponseResult;
import com.booker.utils.response.MyResponseStatus;
import com.booker.utils.response.exception.ForbiddenException;
import com.booker.utils.response.exception.ParamErrorException;
import com.booker.utils.response.exception.ResourcesNotFoundException;
import com.booker.utils.response.exception.TokenInvalidException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.mail.MailSendException;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import javax.mail.SendFailedException;
import javax.validation.ConstraintViolationException;
import java.util.List;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.BAD_REQUEST)
    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseResult parameterMissingExceptionHandler(MissingServletRequestParameterException e) {
        log.error("Missing Parameter", e);
        return new ResponseResult(MyResponseStatus.PARAM_NOT_PRESENT.getCode(), "缺少参数：" + e.getParameterName());
    }

    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.BAD_REQUEST)
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseResult parameterBodyMissingExceptionHandler(HttpMessageNotReadableException e) {
        log.error("Missing Parameter Body", e);
        return new ResponseResult(MyResponseStatus.PARAM_NOT_PRESENT.getCode(), "参数体不能为空");
    }

    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.PRECONDITION_FAILED)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseResult parameterExceptionHandler(MethodArgumentNotValidException e) {
        log.error("Parameter Verification Error", e);
        // 获取异常信息
        BindingResult exceptions = e.getBindingResult();
        // 判断异常中是否有错误信息，如果存在就使用异常中的消息，否则使用默认消息
        if (exceptions.hasErrors()) {
            List<ObjectError> errors = exceptions.getAllErrors();
            if (!errors.isEmpty()) {
                // 这里列出了全部错误参数，按正常逻辑，只需要第一条错误即可
                FieldError fieldError = (FieldError) errors.get(0);
                return new ResponseResult(MyResponseStatus.PARAM_FORMAT_ERROR.getCode(), fieldError.getDefaultMessage());
            }
        }
        return new ResponseResult(MyResponseStatus.PARAM_FORMAT_ERROR);
    }

    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.PRECONDITION_FAILED)
    @ExceptionHandler({ParamErrorException.class})
    public ResponseResult paramExceptionHandler(ParamErrorException e) {
        log.error("Parameter Verification Error", e);
        // 判断异常中是否有错误信息，如果存在就使用异常中的消息，否则使用默认消息
        if (!StringUtils.isEmpty(e.getMessage())) {
            return new ResponseResult(MyResponseStatus.PARAM_FORMAT_ERROR.getCode(), e.getMessage());
        }
        return new ResponseResult(MyResponseStatus.PARAM_FORMAT_ERROR);
    }

    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.PRECONDITION_FAILED)
    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseResult paramExceptionHandler(ConstraintViolationException e) {
        log.error("Parameter Verification Error", e);
        return new ResponseResult(MyResponseStatus.PARAM_FORMAT_ERROR.getCode(), "参数数据格式错误："+e.getMessage());
    }

    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.UNAUTHORIZED)
    @ExceptionHandler(TokenInvalidException.class)
    public ResponseResult tokenInvalidExceptionHandler(TokenInvalidException e) {
        log.error("Token is invalid", e);
        // 判断异常中是否有错误信息，如果存在就使用异常中的消息，否则使用默认消息
        if (!StringUtils.isEmpty(e.getMessage())) {
            return new ResponseResult(MyResponseStatus.PARAM_FORMAT_ERROR.getCode(), e.getMessage());
        }
        return new ResponseResult(MyResponseStatus.TOKEN_INVALID);
    }

    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.NOT_FOUND)
    @ExceptionHandler(ResourcesNotFoundException.class)
    public ResponseResult resourceNotFoundExceptionHandler(ResourcesNotFoundException e) {
        log.error("Resources not found", e);
        // 判断异常中是否有错误信息，如果存在就使用异常中的消息，否则使用默认消息
        if (!StringUtils.isEmpty(e.getMessage())) {
            return new ResponseResult(MyResponseStatus.NOT_FOUNT.getCode(), e.getMessage());
        }
        return new ResponseResult(MyResponseStatus.NOT_FOUNT);
    }

    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.PRECONDITION_FAILED)
    @ExceptionHandler(MailSendException.class)
    public ResponseResult mailSendExceptionHandler(MailSendException e) {
        log.error("Email address is invalid:", e);
        return new ResponseResult(MyResponseStatus.PARAM_FORMAT_ERROR.getCode(), "邮箱地址不存在");
    }

    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.FORBIDDEN)
    @ExceptionHandler(ForbiddenException.class)
    public ResponseResult forbiddenExceptionHandler(ForbiddenException e) {
        log.error("Operation is forbidden:", e);
        // 判断异常中是否有错误信息，如果存在就使用异常中的消息，否则使用默认消息
        if (!StringUtils.isEmpty(e.getMessage())) {
            return new ResponseResult(MyResponseStatus.FORBIDDEN.getCode(), e.getMessage());
        }
        return new ResponseResult(MyResponseStatus.FORBIDDEN);
    }

}

package com.booker.controller;

import com.booker.entity.User;
import com.booker.service.EmailService;
import com.booker.service.UserService;
import com.booker.utils.RedisOperator;
import com.booker.utils.response.exception.ForbiddenException;
import com.booker.utils.response.exception.ParamErrorException;
import com.booker.utils.response.exception.ResourcesNotFoundException;
import com.booker.utils.response.exception.TokenInvalidException;
import io.swagger.annotations.*;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import javax.validation.constraints.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Api(tags = "用户接口", description = "与用户操作相关的接口")
@RestController
@RequestMapping("/user")
@Validated
public class UserController {

    @Autowired
    UserService userService;

    @Autowired
    EmailService emailService;

    @Autowired
    RedisOperator redis;

    @PostMapping("/login")
    @ApiOperation(value = "登录", notes = "接收用户名/邮箱和密码，登录成功，返回Token")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "username", value = "用户名，长度>6，纯数字 或者<br/>邮箱，必须符合邮箱格式", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "password", value = "密码，长度6~16，仅允许包含数字和字母", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功登录"),
            @ApiResponse(code = 404, message = "用户不存在"),
            @ApiResponse(code = 406, message = "密码错误"),
            @ApiResponse(code = 412, message = "数据格式错误")
    })
    public String login(
            HttpServletResponse response,
            @Size(min = 6, message = "用户名长度必须大于6")
            @RequestPart("username") String username,
            @Pattern(regexp = "^[a-zA-Z0-9]\\w{5,15}$", message = "密码必须由6-16位数字或英文字母组成")
            @RequestPart("password") String password
    ) throws IOException {
        int result = userService.checkLoginInfo(username, password);
        String token = null;
        if (result == userService.VALID) {
            token = "user" + username;
            redis.set(token, userService.getUid(username));
        } else if (result == userService.NOT_EXIST) {
            throw new ResourcesNotFoundException("用户不存在");
        } else if (result == userService.WRONG_PWD) {
            response.sendError(406, "密码错误");
        } else {
            throw new ParamErrorException("用户名格式错误");
        }
        return token;
    }

    @GetMapping("")
    @ApiOperation(value = "获取用户信息", notes = "接收Token，返回登录的用户信息")
    @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    @ApiResponses({
            @ApiResponse(code = 200, message = "Token有效，成功获取用户信息"),
            @ApiResponse(code = 401, message = "Token无效/已失效"),
            @ApiResponse(code = 404, message = "Token有效，但Token指定的用户不存在")
    })
    public User getUser(@RequestHeader("token") String token) {
        Long uid = (Long)redis.get(token);
        if (uid != null) {
            User user = userService.getUser(uid);
            if (user != null) {
                return user;
            } else {
                throw new ResourcesNotFoundException("Token指定用户不存在");
            }
        } else {
            throw new TokenInvalidException();
        }
    }

    @PostMapping("/logout")
    @ApiOperation(value = "退出登录", notes = "接收Token，退出登录，删除Token")
    @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    @ApiResponses({
            @ApiResponse(code = 200, message = "Token有效，已删除Token"),
            @ApiResponse(code = 204, message = "Token已经失效，可以直接退出登录")
    })
    public void logout(
            HttpServletResponse response,
            @RequestHeader("token") String token
    ) {
        if (redis.hasKey(token)) {
            redis.delete(token);
            response.setStatus(200);
        } else {
            response.setStatus(204, "Token已经失效，可以直接退出登录");
        }
    }

    @GetMapping("/auth-code")
    @ApiOperation(value = "获取验证码", notes = "接收传递的邮箱，向接收的邮箱发送验证码，同时返回Token")
    @ApiImplicitParam(name = "email", value = "验证邮箱，必须符合邮箱格式", dataTypeClass = String.class, required = true)
    @ApiResponses({
            @ApiResponse(code = 200, message = "验证码已发到邮箱"),
            @ApiResponse(code = 412, message = "邮箱错误")
    })
    public String getAuthCode(
            @Email(message = "邮箱格式不正确")
            @RequestParam("email") String email
    ) {
        int authCode = 1000 + (int)(Math.random()*9000);
        emailService.sendEmail(email, "注册验证码", "验证码：" + authCode);
        String token = "email"+email;
        Map<String, Object> map = new HashMap<>();
        map.put("email", email);
        map.put("authCode", authCode);
        redis.set(token, map);
        return token;
    }

    @PostMapping("/auth-code/confirm")
    @ApiOperation(value = "确认验证码", notes = "接收验证码，检验邮箱是否已注册和验证码是否正确")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "email", value = "用户邮箱，必须符合邮箱格式", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "authCode", value = "验证码", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "token", value = "获取验证码时，拿到的Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "验证通过"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 403, message = "邮箱错误"),
            @ApiResponse(code = 406, message = "验证码错误"),
            @ApiResponse(code = 412, message = "数据格式错误")
    })
    public void confirmCode(
            HttpServletResponse response,
            @RequestHeader("token") String token,
            @Email(message = "邮箱格式错误")
            @RequestPart("email") String email,
            @RequestPart("authCode") String authCode
    ) throws IOException {
        Map<String, Object> map = (Map<String, Object>) redis.get(token);
        if (map != null) {
            String expectEmail = map.get("email").toString();
            if (expectEmail.equals(email)) {
                String expectAuthCode = map.get("authCode").toString();
                if (expectAuthCode.equals(authCode)) {
                    response.setStatus(200);
                } else {
                    response.sendError(406, "验证码错误");
                }
            } else {
                throw new ForbiddenException("邮箱错误");
            }
        } else {
            throw new TokenInvalidException();
        }
    }

    @PutMapping("/password")
    @ApiOperation(value = "修改密码", notes = "接收用户新的密码，返回修改后的用户信息")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "password", value = "新密码，长度6~16，仅允许包含数字和字母", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "密码修改成功"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 404, message = "用户不存在"),
            @ApiResponse(code = 412, message = "密码格式错误")
    })
    public void updatePassword(
            @RequestHeader("token") String token,
            @Pattern(regexp = "^[a-zA-Z0-9]\\w{5,15}$", message = "密码必须由6-16位数字或英文字母组成")
            @RequestPart("password") String password
    ) {
        Object info = redis.get(token);
        if (info != null) {
            Long uid = null;
            if (info instanceof Map) {
                redis.delete(token);
                Map<String, Object> map = (Map<String, Object>) info;
                String email = (String) map.get("email");
                uid = userService.getUid(email);
            } else if (info instanceof Long) {
                uid = (Long) info;
            } else {
                throw new TokenInvalidException();
            }
            if (uid != null) {
                userService.updatePassword(uid, password);
            } else {
                throw new ResourcesNotFoundException("用户不存在");
            }
        } else {
            throw new TokenInvalidException();
        }
    }

    @PostMapping("")
    @ResponseStatus(HttpStatus.CREATED)
    @ApiOperation(value = "注册新用户", notes = "接收用户邮箱、验证码、密码信息，新增用户，并返回新用户")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "user", value = "用户注册信息", required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 201, message = "用户创建成功"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 403, message = "邮箱已注册/邮箱不正确"),
            @ApiResponse(code = 412, message = "数据格式错误")
    })
    public UserAndToken register(
            HttpServletResponse response,
            @RequestHeader("token") String token,
            @Validated
            @RequestBody User user
    ) throws IOException {
        Map<String, Object> map = (Map<String, Object>) redis.get(token);
        String newToken = "";
        User newUser;
        if (map != null) {
            redis.delete(token);
            String email = (String) map.get("email");
            if (email.equals(user.getEmail())) {
                if (!userService.exist(email)) {
                    newUser = userService.add(user);
                    Long uid = newUser.getUid();
                    if (uid != null) {
                        newToken = "user" + uid;
                        redis.set(newToken, uid);
                    } else {
                        response.sendError(500, "注册失败");
                    }
                } else {
                    throw new ForbiddenException("邮箱已注册");
                }
            } else {
                throw new ForbiddenException("邮箱不正确");
            }
        } else {
            throw new TokenInvalidException();
        }
        return new UserAndToken(newToken, newUser);
    }

    @PutMapping("")
    @ApiOperation(value = "修改用户信息", notes = "接收用户信息，修改用户数据")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "user", value = "用户信息", required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "用户信息修改成功"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 404, message = "用户不存在"),
            @ApiResponse(code = 412, message = "数据格式错误")
    })
    public User updateUser(
            @Validated
            @RequestBody User user,
            @RequestHeader("token") String token
    ) throws IllegalAccessException {
        Long uid = (Long) redis.get(token);
        User new_user = null;
        if (uid != null) {
            user.setUid(uid);
            new_user = userService.update(user);
        } else {
            throw new TokenInvalidException();
        }
        return new_user;
    }

    @PutMapping("/head-img")
    @ApiOperation(value = "修改用户头像", notes = "接收图片，然后设置用户头像, 返回头像URL")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "head", value = "用户头像图片，仅允许png、jpg、jpeg格式文件, 文件大小<500KB", dataTypeClass = MultipartFile.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "头像修改成功"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 412, message = "图片格式错误"),
            @ApiResponse(code = 413, message = "图片过大")
    })
    public String setUserHeadImg(
            @RequestPart("head") MultipartFile head,
            @RequestHeader("token") String token
    ) {
        String headImgUrl = "";
        return headImgUrl;
    }

    @GetMapping("/all-tags")
    @ApiOperation(value = "获取所有标签", notes = "为用户注册时提供兴趣标签选择")
    @ApiResponse(code = 200, message = "成功返回标签列表")
    public List<String> getAllInterestTags() {
        return userService.getAllTags();
    }

    @GetMapping("/all-industries")
    @ApiOperation(value = "获取所有行业", notes = "为用户修改行业时提供行业选择")
    @ApiResponse(code = 200, message = "成功返回行业列表")
    public List<String> getAllIndustries() {
        return userService.getAllIndustry();
    }

    @Data
    @ApiModel("新用户信息和Token")
    protected static class UserAndToken {
        @ApiModelProperty("Token")
        private String token;
        @ApiModelProperty("新用户信息")
        private User user;
        public UserAndToken(String token, User user) {
            this.token = token;
            this.user = user;
        }
    }

}

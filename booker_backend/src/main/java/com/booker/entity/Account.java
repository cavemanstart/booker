package com.booker.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import javax.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import javax.persistence.*;

@ApiModel("账户的用户名和密码信息")
@Data
@ToString(exclude = {"user"})
@EqualsAndHashCode(exclude = {"user"})
@Entity
@Table(name = "account")
public class Account {

    @ApiModelProperty(value = "用户名，主键", example = "123456")
    @Id
    @Column(name = "username", columnDefinition = "bigserial")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long username;

    @ApiModelProperty(value = "密码", required = true, example = "123456")
    @Column(name = "password", nullable = false)
//    @NotBlank
//    @Pattern(regexp = "^[a-zA-Z0-9]\\w{5,15}$", message = "密码必须由6-16位数字或英文字母组成")
    private String password;

    @ApiModelProperty(hidden = true)
    @OneToOne(fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    @JoinColumn(name = "uid", nullable = false, unique = true)
    @JsonIgnore
    private User user;

}

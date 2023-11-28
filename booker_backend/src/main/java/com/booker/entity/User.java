package com.booker.entity;

import com.booker.config.GlobalConfig;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.vladmihalcea.hibernate.type.array.StringArrayType;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.hibernate.annotations.*;
import org.hibernate.validator.constraints.Length;
import org.hibernate.validator.constraints.URL;

import javax.persistence.*;
import java.time.LocalDate;

@ApiModel("用户的详细信息")
@Data
@NoArgsConstructor
@Entity
@EqualsAndHashCode(exclude = {"account"})
@DynamicInsert
@DynamicUpdate
@Table(name = "user_info")
@TypeDefs({
        @TypeDef(name = "string_array", typeClass = StringArrayType.class)
})
public class User {

    @ApiModelProperty(hidden = true)
    @Id
    @Column(name = "uid", columnDefinition = "bigserial")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long uid;

    @ApiModelProperty(value = "账户信息", example = "{username: 123456. password: 123456}")
    @OneToOne(mappedBy = "user", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private Account account = new Account();

    @ApiModelProperty(value = "昵称", example = "Nickname")
    @Column(name = "nickname", length = 20)
    @NotBlank(message = "昵称不能空白")
    @Size(min = 1, max = 20, message = "昵称长度不能超过20")
    private String nickname;

    @ApiModelProperty(value = "性别（男: 0, 女: 1）", allowableValues = "[0, 1]", name = "sex", example = "0")
    @Column(name = "sex", columnDefinition = "smallint default 0")
    @NotNull(message = "性别不能为空")
    private Integer sex;

    @ApiModelProperty(value = "年龄", allowableValues = "range[0, infinity]", example = "18")
    @Column(name = "age")
    @NotNull(message = "年龄不能为空")
    @Min(0)
    private Integer age;

    @ApiModelProperty(value = "生日", example = "2021-05-29")
    @Column(name = "birthdate", columnDefinition = "date")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    @NotNull(message = "生日不能为空")
    private LocalDate birthdate;

    @ApiModelProperty(value = "邮箱", required = true, example = "ourselves@163.com")
    @Column(name = "email", nullable = false, unique = true)
    @NotNull(message = "邮箱不能为空")
    @Email(message = "邮箱格式错误")
    private String email;

    @ApiModelProperty(value = "行业", example = "计算机")
    @Column(name = "industry")
    @NotNull(message = "行业不能为空")
    private String industry;

    @Type(type = "string_array")
    @ApiModelProperty(value = "兴趣标签", example = "[f'编程', '架构', '程序']")
    @Column(name = "tags", columnDefinition = "varchar(10)[]")
    @Size(min = 1, message = "最少要选择一个标签")
    private String[] tags;

    @ApiModelProperty(value = "阅读计划", allowableValues = "range[0, infinity]", example = "5")
    @Column(name = "reading_plan", columnDefinition = "integer default 0")
    @Min(0)
    private Integer readingPlan;

    @ApiModelProperty(value = "头像图片url")
    @Column(name = "head_url")
    @URL(message = "头像url格式错误")
    private String headUrl;

    @ApiModelProperty(value = "阅读数", allowableValues = "range[0, infinity]", example = "50")
    @Column(name = "read_num", columnDefinition = "default 0")
    @Min(0)
    private Integer readNum;

    @ApiModelProperty(value = "获赞数", allowableValues = "range[0, infinity]", example = "50")
    @Column(name = "like_num", columnDefinition = "default 0")
    @Min(0)
    private Integer likeNum;

    public User(Long uid) {
        this.uid = uid;
    }

    public Long getUsername() {
        if (this.account == null) {
            return null;
        }
        return account.getUsername();
    }

    public String getPassword() {
        if (this.account == null) {
            return null;
        }
        return account.getPassword();
    }

    public void setUsername(Long username) {
        if (this.account == null) {
            this.account = new Account();
        }
        this.account.setUsername(username);
    }

    public void setPassword(String password) {
        if (this.account == null) {
            this.account = new Account();
        }
        this.account.setPassword(password);
    }

    public String getHeadUrl() {
        String avatarUrl = this.headUrl;
        if (avatarUrl == null) {
            if (sex == 0) {
                avatarUrl = "images/male_avatar.jpg";
            } else {
                avatarUrl = "images/female_avatar.jpg";
            }
        }
        if (avatarUrl.contains("booker")) {
            return avatarUrl;
        }
        return "http://47.117.112.114:8081/booker/" + avatarUrl;
    }

    public String getNickname() {
        return nickname==null?"":nickname;
    }

    public Integer getSex() {
        return sex==null?0:sex;
    }

    public Integer getAge() {
        return age==null?0:age;
    }

    public Integer getReadingPlan() {
        return readingPlan==null?0:readingPlan;
    }

    public Integer getReadNum() {
        return readNum==null?0:readNum;
    }

    public Integer getLikeNum() {
        return likeNum==null?0:likeNum;
    }
}

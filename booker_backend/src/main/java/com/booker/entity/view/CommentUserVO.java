package com.booker.entity.view;

import com.booker.config.GlobalConfig;
import com.fasterxml.jackson.annotation.JsonIgnore;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Value;

import java.io.Serializable;

@Value
@ApiModel("书评的用户信息")
public class CommentUserVO {

    @ApiModelProperty("用户名")
    Long username;

    @ApiModelProperty("昵称")
    String nickname;

    @ApiModelProperty(hidden = true)
    @JsonIgnore
    Integer sex;

    @ApiModelProperty("用户头像")
    String headUrl;

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
}

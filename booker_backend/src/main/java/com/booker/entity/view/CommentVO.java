package com.booker.entity.view;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.Value;

import java.time.LocalDateTime;

@Data
@ApiModel("书评信息")
public class CommentVO {

    @ApiModelProperty(value = "书评ID，主键", required = true, example = "1")
    private Long commentId;

    @ApiModelProperty(value = "点赞数", required = true, allowableValues = "range[0, infinity]", example = "50")
    private int likes;

    @ApiModelProperty(value = "评论时间", required = true, example = "2021-05-29 12:00:00")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime commentTime;

    @ApiModelProperty(value = "对书籍的评分", required = true, example = "6")
    private Double rating;

    @ApiModelProperty(value = "书评内容", required = true, example = "xxxxx")
    private String content;

    @ApiModelProperty(value = "评论用户信息")
    private CommentUserVO user;

    @ApiModelProperty(value = "当前用户是否已点赞")
    private Boolean hasUserLiked;

    public CommentVO(Long commentId, int likes, LocalDateTime commentTime, Double rating, String content, Long username, String nickname, Integer sex, String headUrl) {
        this.commentId = commentId;
        this.likes = likes;
        this.commentTime = commentTime;
        this.rating = rating;
        this.content = content;
        this.user = new CommentUserVO(username, nickname, sex, headUrl);
    }

    public Double getRating() {
        return rating==null?5.0:rating;
    }

}

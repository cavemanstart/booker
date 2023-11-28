package com.booker.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.vladmihalcea.hibernate.type.array.StringArrayType;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

import javax.persistence.Entity;
import javax.persistence.Table;
import javax.validation.constraints.*;
import lombok.Data;
import org.hibernate.annotations.*;
import org.hibernate.validator.constraints.Range;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.Set;

@ApiModel("书评的主要信息")
@Data
@Entity
@Table(name = "comment")
@DynamicInsert
@DynamicUpdate
@TypeDefs({
        @TypeDef(name = "string_array", typeClass = StringArrayType.class)
})
public class Comment {

    @ApiModelProperty(value = "书评ID，主键", required = true, example = "1")
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "comment_id", columnDefinition = "bigserial")
    private Long commentId;

    @ApiModelProperty(value = "点赞数", required = true, allowableValues = "range[0, infinity]", example = "50")
    @Column(name = "likes", columnDefinition = "int DEFAULT 0")
    @Min(0)
    private int likes;

    @ApiModelProperty(value = "评论时间", required = true, example = "2021-05-29 12:00:00")
    @Column(name = "comment_time", columnDefinition = "timestamp DEFAULT ('now'::text)::timestamp(0) with time zone")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime commentTime;

    @ApiModelProperty(value = "对书籍的评分", required = true, example = "6")
    @Column(name = "rating", nullable = false)
    @NotNull(message = "评分不能为空")
    @Range(min = 1, max = 10, message = "评分无效")
    private Double rating;

    @ApiModelProperty(value = "书评内容", required = true, example = "xxxxx")
    @Column(name = "content", nullable = false, columnDefinition = "text not null")
//    @NotBlank(message = "内容不能空白")
    private String content;

    @ApiModelProperty(value = "对书籍评价的标签", required = true, example = "['编程', '计算机']")
    @Transient
    private Set<String> tags;

    @ApiModelProperty(hidden = true)
    @Column(name = "uid")
    @JsonIgnore
    private Long uid;

    @ApiModelProperty(value = "评论发表用户")
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "uid", nullable = false, insertable = false, updatable = false)
    private User user;

    @ApiModelProperty(hidden = true)
    @Column(name = "book")
    @JsonIgnore
    private String bookId;

    @ApiModelProperty(hidden = true)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book", nullable = false, insertable = false, updatable = false)
    private Book book;

    @ApiModelProperty(hidden = true)
    @ManyToMany
    @JoinTable(name = "user_like_comment",
    joinColumns = {@JoinColumn(name = "comment_id")},
    inverseJoinColumns = {@JoinColumn(name = "uid")})
    private Set<User> users;

    @ApiModelProperty(value = "当前用户是否已点赞")
    @Transient
    private Boolean hasUserLiked;

    public Double getRating() {
        return rating==null?5.0:rating;
    }

    public Boolean getHasUserLiked() {
        return hasUserLiked != null && hasUserLiked;
    }

}

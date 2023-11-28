package com.booker.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import javax.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;
import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;

import javax.persistence.*;
import java.time.LocalDateTime;

@ApiModel("读书笔记")
@Data
@Entity
@DynamicInsert
@DynamicUpdate
@ToString(exclude = {"user"})
@EqualsAndHashCode(exclude = {"user"})
@Table(name = "note")
public class Note {

    @ApiModelProperty(value = "读书笔记ID，主键", required = true, example = "1")
    @Id
    @Column(name = "note_id", columnDefinition = "bigserial")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long noteId;

    @ApiModelProperty(value = "标题", required = true, example = "这是一个读书笔记标题")
    @Column(name = "title", nullable = false, length = 30)
    @NotBlank(message = "标题不能空白")
    @Size(min = 1, max = 30)
    private String title;

    @ApiModelProperty(value = "内容", required = true, example = "这些是读书笔记的内容...")
    @Column(name = "content", columnDefinition = "text not null")
//    @NotBlank(message = "内容不能空白")
    private String content;

    @ApiModelProperty(value = "上次编辑时间", required = true, example = "2021-05-29 12:00:00")
    @Column(name = "edit_time", columnDefinition = "timestamp DEFAULT ('now'::text)::timestamp(0) with time zone")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime editTime;

    @ApiModelProperty(hidden = true)
    @ManyToOne
    @JoinColumn(name = "user_book_id", nullable = false)
    @JsonIgnore
    private UserBook userBook;

}

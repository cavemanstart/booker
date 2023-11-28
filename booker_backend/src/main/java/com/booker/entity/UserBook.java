package com.booker.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;
import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@ApiModel("某一用户和某一书籍的关系")
@Data
@Entity
@ToString(exclude = {"book", "reader", "notes"})
@EqualsAndHashCode(exclude = {"book", "reader", "notes"})
@DynamicInsert
@DynamicUpdate
@Table(name = "user_book")
public class UserBook {

    public static final Integer READING = 0;
    public static final Integer READ = 1;

    @ApiModelProperty(hidden = true)
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "user_book_id", columnDefinition = "bigserial")
    private Long userBookId;

    @ApiModelProperty(hidden = true)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reader")
    private User reader;

    @ApiModelProperty(hidden = true)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book")
    private Book book;

    @ApiModelProperty(value = "阅读状态（不在书架: null, 在读: 0, 已读: 1）", required = true, allowableValues = "[0, 1]", example = "0")
    @Column(name = "status")
    private Integer status;  // 在读: 0, 已读: 1

    @ApiModelProperty(hidden = true)
    @Column(name = "mark_time", columnDefinition = "timestamp DEFAULT ('now'::text)::timestamp(0) with time zone")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime markTime;

    @ApiModelProperty(hidden = true)
    @OneToMany(mappedBy = "userBook", fetch = FetchType.LAZY, orphanRemoval = true, cascade = CascadeType.PERSIST)
    private List<Note> notes;

}

package com.booker.entity;

import com.vladmihalcea.hibernate.type.array.StringArrayType;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import javax.validation.constraints.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Type;
import org.hibernate.annotations.TypeDef;
import org.hibernate.annotations.TypeDefs;

import javax.persistence.*;

@ApiModel("书籍信息")
@Data
@NoArgsConstructor
@Entity
@Table(name = "book")
@TypeDefs({
        @TypeDef(name = "string_array", typeClass = StringArrayType.class)
})
public class Book {

    @ApiModelProperty(value = "ISBN号，主键", required = true, example = "9787302392644")
    @Id
    @Column(name = "book_id")
    private String bookId;

    @ApiModelProperty(value = "书名", required = true, example = "人月神话")
    @Column(name = "book_name", nullable = false, columnDefinition = "text")
    @NotBlank(message = "书名不能空白")
    private String bookName;

    @ApiModelProperty(value = "副标题")
    @Column(name = "subtitle", columnDefinition = "text")
    private String subtitle;

    @ApiModelProperty(value = "作者")
    @Column(name = "author", columnDefinition = "text")
    private String author;

    @ApiModelProperty(value = "出版社")
    @Column(name = "publisher", columnDefinition = "text")
    private String publisher;

    @ApiModelProperty(value = "出版时间")
    @Column(name = "publish_time")
    private String publishDate;

    @ApiModelProperty(hidden = true)
    @Column(name = "degree")
    private Double degree;

    @ApiModelProperty(value = "页数")
    @Column(name = "page_num")
    @Min(0)
    private String pageNum;

    @ApiModelProperty(value = "价格")
    @Column(name = "price")
    private String price;

    @ApiModelProperty(value = "简介")
    @Type(type = "string_array")
    @Column(name = "brief", columnDefinition = "text[]")
    private String[] brief;

    @ApiModelProperty(value = "标签")
    @Type(type = "string_array")
    @Column(name = "tags", columnDefinition = "varchar[]")
    private String[] tags;

    @ApiModelProperty(value = "书籍封面")
    @Column(name = "cover_img")
    private String coverImgUrl;

    public String getCoverImgUrl() {
        String coverImg = this.coverImgUrl;
        if (this.coverImgUrl == null) {
            coverImg = "images/default.jpg";
        }
        if (!coverImg.contains("booker")) {
            coverImg = "http://47.117.112.114:8081/booker/" + coverImg;
        }
        return coverImg;
    }

    public Book(String bookId) {
        this.bookId = bookId;
    }

    public Double getDegree() {
        return degree==null?0.0:degree;
    }

}

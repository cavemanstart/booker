package com.booker.entity.view;

import com.booker.entity.Book;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Value;

@Value
@AllArgsConstructor
@ApiModel("图书列表中每个图书的信息")
public class SimpleBookVO {

    @ApiModelProperty("作者")
    String author;

    @ApiModelProperty("ISBN号")
    String bookId;

    @ApiModelProperty("书名")
    String bookName;

    @ApiModelProperty("副标题")
    String subtitle;

    @ApiModelProperty("出版日期")
    String publishDate;

    @ApiModelProperty("出版社")
    String publisher;

    @ApiModelProperty("封面图片URL")
    String coverImgUrl;

    public SimpleBookVO(Book book) {
        this.author = book.getAuthor();
        this.bookId = book.getBookId();
        this.bookName = book.getBookName();
        this.subtitle = book.getSubtitle();
        this.publisher = book.getPublisher();
        this.publishDate = book.getPublishDate();
        this.coverImgUrl = book.getCoverImgUrl();
    }

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

}

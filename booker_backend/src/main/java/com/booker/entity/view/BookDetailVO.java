package com.booker.entity.view;

import com.booker.entity.Book;
import com.booker.entity.view.CommentVO;
import com.booker.entity.view.RatingStatistics;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@ApiModel("图书详细信息")
public class BookDetailVO {

    @ApiModelProperty("图书基本信息")
    private Book book;

    @ApiModelProperty(value = "书籍评论列表（5条）")
    private List<CommentVO> comments;

    @ApiModelProperty("图书评分统计信息")
    private RatingStatistics ratingStatics;

    @ApiModelProperty("阅读状态（在读: 0, 已读: 1, 未加入书架: null）")
    private Integer status;

    public BookDetailVO(Book book, List<CommentVO> comments, RatingStatistics ratingStatics, Integer status) {
        this.book = book;
        this.comments = comments;
        this.ratingStatics = ratingStatics;
        this.status = status;
    }
}


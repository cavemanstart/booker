package com.booker.service;

import com.booker.entity.Comment;
import com.booker.entity.view.CommentVO;

import java.util.List;

public interface CommentService {
    List<CommentVO> getBookComments(String bookId, Long uid);

    boolean exist(String bookId, Long uid);

    boolean exist(Long commentId);

    Comment add(String bookId, Comment comment);

    void like(Long commentId, Long uid);

    void unlike(Long commentId, Long uid);

    boolean hasLiked(Long commentId, Long uid);
}

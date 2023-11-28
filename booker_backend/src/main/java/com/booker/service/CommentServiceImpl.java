package com.booker.service;

import com.alibaba.fastjson.JSON;
import com.booker.entity.Book;
import com.booker.entity.Comment;
import com.booker.entity.view.CommentVO;
import com.booker.repository.BookRepository;
import com.booker.repository.CommentRepository;
import com.booker.repository.message.BooksDataMessageRepository;
import com.booker.repository.message.UserCollectionsMessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CommentServiceImpl implements CommentService {

    @Autowired
    CommentRepository commentRepository;

    @Autowired
    BookRepository bookRepository;

    @Autowired
    private UserCollectionsMessageRepository userCollectionsMessageRepository;

    @Autowired
    private BooksDataMessageRepository booksDataMessageRepository;

    @Override
    public List<CommentVO> getBookComments(String bookId, Long uid) {
        List<Map<String, Object>> maps = commentRepository.findAllVOByBookId(bookId);
        List<CommentVO> comments = JSON.parseArray(JSON.toJSONString(maps), CommentVO.class);
        for (CommentVO comment : comments) {
            comment.setHasUserLiked(commentRepository.hasUserLiked(comment.getCommentId(), uid));
        }
        return comments;
    }

    @Override
    public boolean exist(String bookId, Long uid) {
        return commentRepository.findByBookIdAndUid(bookId, uid).isPresent();
    }

    @Override
    public boolean exist(Long commentId) {
        return commentRepository.findById(commentId).isPresent();
    }

    @Override
    public Comment add(String bookId, Comment comment) {
        comment.setBookId(bookId);
        Set<String> tagSet = new HashSet<>();
        for (String tags : bookRepository.findTagsByBookId(bookId)) {
            for (String tag : tags.split(",")) {
                if (tag != null && !tag.trim().isEmpty()) {
                    System.out.println(tag);
                    tagSet.add(tag.trim());
                }
            }
        }
        System.out.println(tagSet);
        for (String tag : comment.getTags()) {
            if (tag!=null && !tag.trim().isEmpty()) {
                System.out.println(tag);
                tagSet.add(tag.trim());
            }
        }
        System.out.println(tagSet);
        String[] tags = tagSet.toArray(new String[0]);
        bookRepository.updateTagsById(bookId, tags);
        Comment newComment = commentRepository.saveAndFlush(comment);
        userCollectionsMessageRepository.send(comment.getUid(), bookId, comment.getRating(), "update");
        Optional<Book> bookResult = bookRepository.findById(bookId);
        Book book = null;
        if (bookResult.isPresent()) {
            book = bookResult.get();
        }
        if (book != null) {
            booksDataMessageRepository.send(bookId, comment.getTags().toArray(new String[0]), book.getDegree());
        }
        Optional<Comment> result = commentRepository.findById(newComment.getCommentId());
        return result.orElse(newComment);
    }

    @Override
    public boolean hasLiked(Long commentId, Long uid) {
        return commentRepository.checkLikeByCommentIdAndUid(commentId, uid);
    }

    @Override
    public void like(Long commentId, Long uid) {
        if (hasLiked(commentId, uid)) {
            return;
        }
        commentRepository.insertLikeByCommentIdAndUid(commentId, uid);
    }

    @Override
    public void unlike(Long commentId, Long uid) {
        if (!hasLiked(commentId, uid)) {
            return;
        }
        commentRepository.deleteLikeByCommentIdAndUid(commentId, uid);
    }
}

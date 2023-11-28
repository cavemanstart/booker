package com.booker.service;

import com.booker.entity.Book;
import com.booker.entity.UserBook;
import com.booker.entity.view.SimpleBookVO;
import com.booker.repository.CommentRepository;
import com.booker.repository.UserBookRepository;
import com.booker.repository.message.UserCollectionsMessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserBookServiceImpl implements UserBookService {

    @Autowired
    UserBookRepository userBookRepository;

    @Autowired
    CommentRepository commentRepository;

    @Autowired
    private UserCollectionsMessageRepository userCollectionsMessageRepository;

    @Override
    public List<SimpleBookVO> getReadList(Long uid) {
        return userBookRepository.findBookListByUidAndStatus(uid, UserBook.READ);
    }

    @Override
    public List<SimpleBookVO> getReadingList(Long uid) {
        return userBookRepository.findBookListByUidAndStatus(uid, UserBook.READING);
    }

    @Override
    public void setReading(String bookId, Long uid) {
        setStatus(bookId, uid, UserBook.READING);
        userCollectionsMessageRepository.send(uid, bookId, 5.0, "update");
    }

    @Override
    public void setHasRead(String bookId, Long uid) {
        setStatus(bookId, uid, UserBook.READ);
    }

    @Override
    public void setStatus(String bookId, Long uid, Integer status) {
        UserBook userBook = userBookRepository.findOneByBookAndUser(bookId ,uid);
        if (userBook != null) {
            userBook.setStatus(status);
            userBookRepository.save(userBook);
        } else {
            userBookRepository.insertOne(bookId, uid, status);
        }
    }

    @Override
    public boolean exist(String bookId, Long uid) {
        UserBook userBook = userBookRepository.findOneByBookAndUser(bookId, uid);
        return userBook != null;
    }

    @Override
    public void remove(String bookId, Long uid) {
        userBookRepository.deleteByBookAndUser(bookId, uid);
        commentRepository.deleteAllByBookAndUser(bookId, uid);
        userCollectionsMessageRepository.send(uid, bookId, 0.0, "delete");
    }
}

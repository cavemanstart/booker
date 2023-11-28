package com.booker.service;

import com.booker.entity.Book;
import com.booker.entity.view.SimpleBookVO;

import java.util.List;

public interface UserBookService {
    List<SimpleBookVO> getReadList(Long uid);

    List<SimpleBookVO> getReadingList(Long uid);

    void setReading(String bookId, Long uid);

    void setHasRead(String bookId, Long uid);

    void setStatus(String bookId, Long uid, Integer status);

    boolean exist(String bookId, Long uid);

    void remove(String bookId, Long uid);
}

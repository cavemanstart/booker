package com.booker.service;

import com.booker.entity.Book;
import com.booker.entity.view.BookDetailVO;
import com.booker.entity.view.SimpleBookVO;

import java.net.URISyntaxException;
import java.util.List;
import java.util.Set;

public interface BookService {

    String recommendBaseUrl = "http://39.103.210.93:9000/recommend";

    Book getBook(String bookId);

    BookDetailVO getBookDetail(String bookId, Long uid);

    Set<String> getBookTags(String bookId);

    List<SimpleBookVO> getPersonalRecmdBooks(Long uid, int limit) throws URISyntaxException;

    List<SimpleBookVO> searchBooks(String searchValue, Integer page, Integer size);

    List<SimpleBookVO> getHighRatingRecmdBooks(int limit);

    List<SimpleBookVO> getPopularRecmdBooks(int limit);
}

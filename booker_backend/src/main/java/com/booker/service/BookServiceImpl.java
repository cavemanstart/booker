package com.booker.service;

import com.alibaba.fastjson.JSON;
import com.booker.entity.Book;
import com.booker.entity.User;
import com.booker.entity.view.BookDetailVO;
import com.booker.entity.UserBook;
import com.booker.entity.view.CommentVO;
import com.booker.entity.view.RatingStatistics;
import com.booker.entity.view.SimpleBookVO;
import com.booker.repository.BookRepository;
import com.booker.repository.CommentRepository;
import com.booker.repository.UserBookRepository;
import com.booker.repository.UserRepository;
import com.booker.repository.message.RealTimeMessageRepository;
import com.booker.utils.response.exception.ParamErrorException;
import com.booker.utils.response.exception.ResourcesNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;

import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;

@Service
public class BookServiceImpl implements BookService {

    @Autowired
    private BookRepository bookRepository;

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private UserBookRepository userBookRepository;

    @Autowired
    private UserService userService;

    @Autowired
    private RealTimeMessageRepository realTimeMessageRepository;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    public Book getBook(String bookId) {
        Optional<Book> result = bookRepository.findById(bookId);
        Book book = null;
        if (result.isPresent()) {
            book = result.get();
        }
        return book;
    }

    @Override
    public BookDetailVO getBookDetail(String bookId, Long uid) {
        Book book = getBook(bookId);
        if (book == null) {
            throw new ResourcesNotFoundException("书籍不存在");
        }
        List<Map<String, Object>> commentMaps = commentRepository.findLimitByBookId(bookId, 5);
        List<CommentVO> comments = JSON.parseArray(JSON.toJSONString(commentMaps), CommentVO.class);
        for (CommentVO comment : comments) {
            comment.setHasUserLiked(commentRepository.hasUserLiked(comment.getCommentId(), uid));
        }
        RatingStatistics ratingStatistics = commentRepository.getRatingBaseInfo(bookId);
        Long total = ratingStatistics.getSumOfRating();
        if (total > 0) {
            ratingStatistics.setOneStar(commentRepository.getSumOfRatingBetween(bookId, 0.0, 2.0) / (double) total);
            ratingStatistics.setTwoStar(commentRepository.getSumOfRatingBetween(bookId, 2.0, 4.0) / (double) total);
            ratingStatistics.setThreeStar(commentRepository.getSumOfRatingBetween(bookId, 4.0, 6.0) / (double) total);
            ratingStatistics.setFourStar(commentRepository.getSumOfRatingBetween(bookId, 6.0, 8.0) / (double) total);
            ratingStatistics.setFiveStar(commentRepository.getSumOfRatingBetween(bookId, 8.0, 10.0) / (double) total);
        }
        UserBook userBook = userBookRepository.findOneByBookAndUser(bookId, uid);
        Integer status = null;
        if (userBook != null) {
            status = userBook.getStatus();
        }
        realTimeMessageRepository.send(uid, bookId);
        return new BookDetailVO(book, comments, ratingStatistics, status);
    }

    @Override
    public Set<String> getBookTags(String bookId) {
        return bookRepository.findTagsByBookId(bookId);
    }

    private String getParamsStr(Map<String, String> params) {
        StringBuilder paramStr = new StringBuilder("?");

        for (String key : params.keySet()) {
            paramStr.append(key).append("=").append(params.get(key)).append("&");
        }

        if (paramStr.length() > 0) {
            paramStr.deleteCharAt(paramStr.length() - 1);
        }

        return paramStr.toString();
    }

    @Override
    public List<SimpleBookVO> getPersonalRecmdBooks(Long uid, int limit) throws URISyntaxException {

        User user = userService.getUser(uid);

        String[] tags = user.getTags();

        if (tags == null || tags.length == 0) {
            return new ArrayList<>();
        }

        Set<String> tagSet = new HashSet<>();
        for (String tag : tags) {
            if (tag != null && !tag.trim().isEmpty()) {
                tagSet.add(tag.trim());
            }
        }

        StringBuilder tagsString = new StringBuilder();
        for (String tag : tagSet) {
            tagsString.append(tag).append("|");
        }
        if (tagsString.length() > 0) {
            tagsString.deleteCharAt(tagsString.length() - 1);
        }

        Map<String, String> params = new HashMap<>();
        params.put("uid", uid.toString());
        params.put("tags", tagsString.toString());

        String paramsStr = getParamsStr(params);


        String url = recommendBaseUrl + "/personal" +paramsStr;

        List<Long> bookIdList = new ArrayList<>();

        try {
            bookIdList = this.restTemplate.getForObject(url, ArrayList.class);
        } catch (HttpServerErrorException e) {
            e.getStatusCode();
            e.printStackTrace();
            throw new ParamErrorException(e.getMessage());
        }
        if (bookIdList.size() >= limit) {
            return getBooks(bookIdList.subList(0, limit));
        } else {
            return new ArrayList<>();
        }
    }

    private List<SimpleBookVO> getBooks(List<Long> bookIdList) {
        List<SimpleBookVO> books = new ArrayList<>();
        List<String> bookIdStrList = new ArrayList<>();
        for (Long bookId : bookIdList) {
            bookIdStrList.add(bookId.toString());
        }

        List<Book> bookList = bookRepository.findAllById(bookIdStrList);

        for (Book book : bookList) {
            books.add(new SimpleBookVO(book));
        }
        return books;
    }

    @Override
    public List<SimpleBookVO> searchBooks(String searchValue, Integer page, Integer size) {
        String[] targetArr = searchValue.split("\\s+");
        Set<String> targets = new HashSet<>();
        for (String target : targetArr) {
            if (target != null && !target.trim().isEmpty()) {
                targets.add(target.trim());
            }
        }

        Pageable pageable = PageRequest.of(page, size);

        List<Book> result = bookRepository.findAll(new Specification<Book>(){
            @Override
            public Predicate toPredicate(Root<Book> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
                List<Predicate> predicates = new ArrayList<>();

                for (String target : targets) {
                    predicates.add(cb.like(root.get("bookName"), "%"+target+"%"));
                    predicates.add(cb.like(root.get("subtitle"), "%" + target + "%"));
                }

                Predicate finalPre = cb.or(predicates.toArray(new Predicate[0]));

                return query.where(finalPre).getRestriction();
            }
        }, pageable).getContent();

        List<SimpleBookVO> books = new ArrayList<>();
        for (Book book : result) {
            SimpleBookVO simpleBook = new SimpleBookVO(book);
            books.add(simpleBook);
        }

        return books;
    }

    @Override
    public List<SimpleBookVO> getHighRatingRecmdBooks(int limit) {
        String url = recommendBaseUrl + "/highRating";

        List<Long> bookIdList;

        try {
            bookIdList = this.restTemplate.getForObject(url, ArrayList.class);
        } catch (HttpServerErrorException e) {
            e.getStatusCode();
            e.printStackTrace();
            throw new ParamErrorException(e.getMessage());
        }
        if (bookIdList.size() >= limit) {
            return getBooks(bookIdList.subList(0, limit));
        } else {
            return new ArrayList<>();
        }
    }

    @Override
    public List<SimpleBookVO> getPopularRecmdBooks(int limit) {
        String url = recommendBaseUrl + "/popular";

        List<Long> bookIdList;

        try {
            bookIdList = this.restTemplate.getForObject(url, ArrayList.class);
        } catch (HttpServerErrorException e) {
            e.getStatusCode();
            e.printStackTrace();
            throw new ParamErrorException(e.getMessage());
        }
        if (bookIdList.size() >= limit) {
            return getBooks(bookIdList.subList(0, limit));
        } else {
            return new ArrayList<>();
        }
    }
}

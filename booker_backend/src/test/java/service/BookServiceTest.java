package service;

import com.booker.BookerApplication;
import com.booker.entity.Book;
import com.booker.entity.Comment;
import com.booker.entity.view.BookDetailVO;
import com.booker.entity.view.SimpleBookVO;
import com.booker.service.BookService;
import com.booker.service.CommentService;
import com.booker.service.UserBookService;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.net.URISyntaxException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@SpringBootTest(classes = BookerApplication.class)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class BookServiceTest {

    @Autowired
    private BookService bookService;

    @Autowired
    private UserBookService userBookService;

    @Autowired
    private CommentService commentService;

    private static final String testBookId = "1234567891234";

    private static final Long testUid = 123456L;

    @Test
    @Order(1)
    public void beforeAll() {
        userBookService.setReading(testBookId, testUid);
        Comment testComment = new Comment();
        testComment.setContent("content");
        testComment.setBookId(testBookId);
        testComment.setUid(testUid);
        testComment.setRating(6.0);
        testComment.setTags(new HashSet<String>(){{
            add("编程"); add("计算机");
        }});
        testComment = commentService.add(testBookId, testComment);
        Long testCommentId = testComment.getCommentId();
        assertNotNull(testCommentId);
    }

    @Test
    @Order(2)
    public void getBookTagsTest() {
        Set<String> tags = bookService.getBookTags(testBookId);
        System.out.println(tags);
        assertNotNull(tags);
    }

    @Test
    @Order(3)
    public void getBookTest() {
        Book book = bookService.getBook(testBookId);
        assertNotNull(book);
    }

    @Test
    @Order(4)
    public void getBookDetailTest() {
        BookDetailVO book = bookService.getBookDetail(testBookId, testUid);
        System.out.println(book);
        assertNotNull(book);
    }

    @Test
    @Order(5)
    public void searchBooksTest() {
        List<SimpleBookVO> books = bookService.searchBooks("软件工程 方法", 0, 50);
        assertNotNull(books);
    }

    @Test
    @Order(6)
    public void getPersonalRecmdBooksTest() throws URISyntaxException {
        List<SimpleBookVO> books = bookService.getPersonalRecmdBooks(123456L, 3);
        assertNotEquals(0, books.size());
    }

    @Test
    @Order(7)
    public void getHighRatingRecmdBooksTest() {
        List<SimpleBookVO> books = bookService.getHighRatingRecmdBooks(50);
        assertNotEquals(0, books.size());
    }

    @Test
    @Order(8)
    public void getPopularRecmdBooksTest() {
        List<SimpleBookVO> books = bookService.getPopularRecmdBooks(50);
        assertNotEquals(0, books.size());
    }

    @Test
    @Order(9)
    public void afterAll() {
        userBookService.remove(testBookId, testUid);
    }

}

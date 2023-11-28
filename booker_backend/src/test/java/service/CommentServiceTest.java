package service;

import com.booker.BookerApplication;
import com.booker.entity.Book;
import com.booker.entity.Comment;
import com.booker.entity.User;
import com.booker.entity.view.CommentVO;
import com.booker.repository.CommentRepository;
import com.booker.service.CommentService;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;

@SpringBootTest(classes = BookerApplication.class)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class CommentServiceTest {

    @Autowired
    private CommentService commentService;

    @Autowired
    private CommentRepository commentRepository;

    private static final String testBookId = "1234567891234";

    private static final Long testUid = 123456L;

    private static Long testCommentId;

    private static Comment testComment;

    @BeforeEach
    public void startup() {
        testComment = new Comment();
        testComment.setContent("content");
        testComment.setBookId(testBookId);
        testComment.setUid(testUid);
        testComment.setRating(6.0);
        testComment.setTags(new HashSet<String>(){{
            add("编程"); add("计算机");
        }});
    }

    @Test
    @Order(1)
    public void addTest() {
        testComment = commentService.add(testBookId, testComment);
        testCommentId = testComment.getCommentId();
        assertNotNull(testCommentId);
    }

    @Test
    @Order(2)
    public void checkExistByBookAndUserTest() {
        boolean exist = commentService.exist(testBookId, testUid);
        assertTrue(exist);
    }

    @Test
    @Order(3)
    public void checkExistByIdTest() {
        boolean exist = commentService.exist(testCommentId);
        assertTrue(exist);
    }

    @Test
    @Order(4)
    public void getBookCommentsTest() {
        List<CommentVO> comments = commentService.getBookComments(testBookId, testUid);
        assertNotEquals(0, comments.size());
    }

    @Test
    @Order(5)
    public void likeTest() {
        commentService.like(testCommentId, testUid);
    }

    @Test
    @Order(6)
    public void hasLikedTest() {
        boolean like = commentService.hasLiked(testCommentId, testUid);
        assertTrue(like);
    }

    @Test
    @Order(7)
    public void unlikeTest() {
        commentService.unlike(testCommentId, testUid);
        boolean like = commentService.hasLiked(testCommentId, testUid);
        assertFalse(like);
    }

    @Test
    @Order(8)
    public void afterAll() {
        commentRepository.deleteById(testCommentId);
    }

}

package service;

import com.booker.BookerApplication;
import com.booker.entity.Comment;
import com.booker.service.AnalyseService;
import com.booker.service.CommentService;
import com.booker.service.UserBookService;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.HashSet;
import java.util.List;

@SpringBootTest(classes = BookerApplication.class)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class AnalyseServiceTest {

    @Autowired
    private AnalyseService analyseService;

    @Autowired
    private UserBookService userBookService;

    @Autowired
    private CommentService commentService;

    private static final Long testUid = 123456L;

    private static final String testBookId = "1234567891234";

    private static final Integer testReadingPlan = 12;

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
    public void setReadingPlanTest() {
        analyseService.setReadingPlan(testUid, testReadingPlan);
    }

    @Test
    @Order(3)
    public void getReadingPlanTest() {
        int readingPlan = analyseService.getReadingPlan(testUid);
        assertEquals(testReadingPlan, readingPlan);
    }

    @Test
    @Order(4)
    public void getReadingHistoryTest() {
        List<Integer> history = analyseService.getReadHistory(testUid);
        assertNotNull(history);
    }

    @Test
    @Order(5)
    public void getInterestTagsTest() {
        List<String> tags = analyseService.getInterestTags(testUid, 10);
        assertNotNull(tags);
    }

    @Test
    @Order(5)
    public void afterAll() {
        userBookService.remove(testBookId, testUid);
    }


}

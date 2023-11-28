package service;

import com.booker.BookerApplication;
import com.booker.entity.view.SimpleBookVO;
import com.booker.service.UserBookService;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

@SpringBootTest(classes = BookerApplication.class)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class UserBookServiceTest {

    @Autowired
    private UserBookService userBookService;

    private static final Long testUid = 123456L;
    private static final String testBookId = "1234567891234";

    @Test
    @Order(1)
    public void setReadingTest() {
        userBookService.setReading(testBookId, testUid);
    }

    @Test
    @Order(2)
    public void getReadingList() {
        List<SimpleBookVO> books = userBookService.getReadingList(testUid);
        assertNotEquals(0, books.size());
    }

    @Test
    @Order(3)
    public void setHasReadTest() {
        userBookService.setHasRead(testBookId, testUid);
    }

    @Test
    @Order(4)
    public void getReadListTest() {
        List<SimpleBookVO> books = userBookService.getReadList(testUid);
        assertNotEquals(0, books.size());
    }

    @Test
    @Order(5)
    public void existTest() {
        boolean exist = userBookService.exist(testBookId, testUid);
        assertTrue(exist);
    }

    @Test
    @Order(6)
    public void removeTest() {
        userBookService.remove(testBookId, testUid);
    }

}

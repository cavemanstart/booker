package service;

import com.booker.BookerApplication;
import com.booker.entity.User;
import com.booker.repository.UserRepository;
import com.booker.service.UserService;
import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

@SpringBootTest(classes = BookerApplication.class)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class UserServiceTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    private static Long testUid;

    private static Long testUsername;

    private final static String testEmail = "testuser@qq.com";

    private final static String testPassword = "123456";

    @Test
    @Order(1)
    public void addTest() {
        User user = new User();
        user.setEmail(testEmail);
        user.setPassword(testPassword);
        user.setNickname("test_user");
        user.setAge(24);
        user.setSex(0);
        user.setIndustry("计算机");
        user.setTags(new String[]{"编程","设计"});
        User testUser = userService.add(user);
        testUid = testUser.getUid();
        testUsername = testUser.getUsername();
        System.out.println(testUser);
        assertNotNull(testUid);
    }

    @Test
    @Order(2)
    public void checkLoginInfoTest() {
        int result = userService.checkLoginInfo(testEmail, testPassword);
        assertEquals(userService.VALID, result);
    }

    @Test
    @Order(3)
    public void getUserByUidTest() {
        User user = userService.getUser(testUid);
        assertNotNull(user);
    }

    @Test
    @Order(4)
    public void getUserByEmailTest() {
        User user = userService.getUser(testEmail);
        assertNotNull(user);
    }

    @Test
    @Order(5)
    public void getUidByUsernameTest() {
        Long uid = userService.getUid(testUsername.toString());
        assertEquals(testUid, uid);
    }

    @Test
    @Order(6)
    public void getUidByEmailTest() {
        Long uid = userService.getUid(testEmail);
        assertEquals(testUid, uid);
    }

    @Test
    @Order(7)
    public void updateTest() throws IllegalAccessException {
        User user = userService.getUser(testUid);
        user.setNickname("user_test");
        userService.update(user);
    }

    @Test
    @Order(8)
    public void updatePassTest() {
        userService.updatePassword(testUid, testPassword);
    }

    @Test
    @Order(8)
    public void existTest() {
        boolean exist =  userService.exist(testEmail);
        assertTrue(exist);
    }

    @Test
    @Order(9)
    public void getAllTagsTest() {
        List<String> tags = userService.getAllTags();
        assertNotNull(tags);
    }

    @Test
    @Order(10)
    public void getAllIndustryTest() {
        List<String> industries = userService.getAllIndustry();
        assertNotNull(industries);
    }

    @Test
    @Order(11)
    public void teardown() {
        userRepository.deleteById(testUid);
    }
}

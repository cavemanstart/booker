package service;

import com.booker.BookerApplication;
import com.booker.entity.Note;
import com.booker.service.NoteService;
import com.booker.service.UserBookService;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

@SpringBootTest(classes = BookerApplication.class)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class NoteServiceTest {

    @Autowired
    private NoteService noteService;

    @Autowired
    private UserBookService userBookService;

    private static final Long testUid = 123456L;

    private static final String testBookId = "1234567891234";

    private static Long testNoteId;

    private static Note testNote;

    @BeforeEach
    public void startup() {
        testNote = new Note();
        testNote.setTitle("title");
        testNote.setContent("content");
    }

    @Test
    @Order(1)
    public void beforeAll() {
        userBookService.setReading(testBookId, testUid);
    }

    @Test
    @Order(2)
    public void addTest() {
        testNote = noteService.add(testUid, testBookId, testNote);
        testNoteId = testNote.getNoteId();
        assertNotNull(testNoteId);
    }

    @Test
    @Order(3)
    public void getNoteTest() {
        Note note = noteService.getNote(testNoteId);
        assertNotNull(note);
    }

    @Test
    @Order(4)
    public void updateTest() throws IllegalAccessException {
        testNote = noteService.update(testNoteId, testNote);
        assertNotNull(testNote);
    }

    @Test
    @Order(5)
    public void getNoteListTest() {
        List<Note> notes = noteService.getNoteList(testUid, testBookId);
        assertNotEquals(0, notes.size());
    }

    @Test
    @Order(6)
    public void removeTest() {
        noteService.remove(testNoteId);
    }

    @Test
    @Order(7)
    public void afterAll() {
        userBookService.remove(testBookId, testUid);
    }

}

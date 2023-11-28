package com.booker.controller;

import com.booker.entity.Note;
import com.booker.entity.UserBook;
import com.booker.service.BookService;
import com.booker.service.NoteService;
import com.booker.service.UserBookService;
import com.booker.utils.RedisOperator;
import com.booker.utils.response.exception.ResourcesNotFoundException;
import com.booker.utils.response.exception.TokenInvalidException;
import io.swagger.annotations.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

@Api(tags = "读书笔记接口", description = "与读书笔记相关操作接口")
@RestController
@RequestMapping("/note")
@Validated
public class NoteController {

    @Autowired
    private NoteService noteService;

    @Autowired
    private UserBookService userBookService;

    @Autowired
    RedisOperator redis;

    @GetMapping("/list/{bookId}")
    @ApiOperation(value = "获取读书笔记列表", notes = "返回用户，对于一般书列表")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "bookId", value = "书籍ISBN号", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功获取读书笔记列表"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 404, message = "书籍不在书架")
    })
    public List<Note> getNoteList(
            @PathVariable("bookId") String bookId,
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        List<Note> notes = new ArrayList<>();
        if (uid != null) {
            if (userBookService.exist(bookId, uid)) {
                notes = noteService.getNoteList(uid, bookId);
            } else {
                throw new ResourcesNotFoundException("书籍不在书架");
            }
        } else {
            throw new TokenInvalidException();
        }
        return notes;
    }

    @GetMapping("/{noteId}")
    @ApiOperation(value = "获取读书笔记详细信息", notes = "通过读书笔记Id，查询并返回读书笔记的具体信息")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "noteId", value = "读书笔记ID", dataTypeClass = Long.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功获取读书笔记详细信息"),
            @ApiResponse(code = 401, message = "Token失效")
    })
    public Note getNote(
            @PathVariable("noteId") Long noteId,
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        Note note = null;
        if (uid != null) {
            note = noteService.getNote(noteId);
        } else {
            throw new TokenInvalidException();
        }
        return note;
    }

    @PostMapping("")
    @ApiOperation(value = "新增读书笔记", notes = "接收读书笔记信息，新增读书笔记")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "bookId", value = "书籍ISBN号", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "note", value = "读书笔记详细信息", required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 201, message = "成功添加读书笔记，返回新增读书笔记"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 412, message = "数据格式错误")
    })
    public Note addNote(
            HttpServletResponse response,
            @RequestHeader("token") String token,
            @RequestParam("bookId") String bookId,
            @Validated
            @RequestBody Note note
    ) {
        Long uid = (Long) redis.get(token);
        Note newNote;
        if (uid != null) {
            newNote = noteService.add(uid, bookId, note);
            response.setStatus(201);
        } else {
            throw new TokenInvalidException();
        }
        return newNote;
    }

    @PutMapping("/{noteId}")
    @ApiOperation(value = "修改读书笔记", notes = "接收读书笔记信息，修改原有数据")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "noteId", value = "读书笔记ID", dataTypeClass = Long.class, required = true),
            @ApiImplicitParam(name = "note", value = "读书笔记修改信息", required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功修改读书笔记内容，返回修改后的读书笔记信息"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 412, message = "数据格式错误")
    })
    public Note updateNote(
            @PathVariable("noteId") Long noteId,
            @RequestHeader("token") String token,
            @RequestBody Note note
    ) throws IllegalAccessException {
        Long uid = (Long) redis.get(token);
        Note newNote = null;
        if (uid != null) {
            newNote = noteService.update(noteId, note);
        } else {
            throw new TokenInvalidException();
        }
        return newNote;
    }

    @DeleteMapping("/{noteId}")
    @ApiOperation(value = "删除读书笔记", notes = "接收读书笔记ID, 删除对应的读书笔记" )
    @ApiImplicitParams({
            @ApiImplicitParam(name = "noteId", value = "读书笔记ID", dataTypeClass = Long.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 204, message = "成功删除读书笔记"),
            @ApiResponse(code = 401, message = "Token失效")
    })
    public void deleteNote(
            HttpServletResponse response,
            @PathVariable("noteId") Long noteId,
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        if (uid != null) {
            noteService.remove(noteId);
            response.setStatus(204);
        } else {
            throw new TokenInvalidException();
        }
    }

}

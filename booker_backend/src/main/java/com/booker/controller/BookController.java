package com.booker.controller;

import com.booker.entity.User;
import com.booker.entity.view.BookDetailVO;
import com.booker.entity.view.SimpleBookVO;
import com.booker.service.BookService;
import com.booker.service.UserBookService;
import com.booker.service.UserService;
import com.booker.utils.RedisOperator;
import com.booker.utils.response.exception.ForbiddenException;
import com.booker.utils.response.exception.ParamErrorException;
import com.booker.utils.response.exception.TokenInvalidException;
import io.swagger.annotations.*;
import org.hibernate.validator.constraints.Range;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.ResourceAccessException;

import javax.servlet.http.HttpServletResponse;
import java.net.URISyntaxException;
import java.util.List;

@Api(tags = "书籍接口", description = "与图书相关操作的接口")
@RestController
@RequestMapping("/book")
@Validated
public class BookController {

    @Autowired
    private BookService bookService;

    @Autowired
    private UserBookService userBookService;

    @Autowired
    private UserService userService;

    @Autowired
    RedisOperator redis;

    @GetMapping("/list/{recommend}")
    @ApiOperation(value = "获取推荐图书列表", notes = "返回个人、热度、高分其中一类推荐的图书列表")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "recommend", value = "推荐类型", allowableValues = "personal, popular, highRating", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "limit", value = "对应推荐类型的前n本书，0<n<=50", allowableValues = "range(1, 50)", dataTypeClass = Integer.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功获取推荐图书信息列表"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 412, message = "数据格式错误")
    })
    public List<SimpleBookVO> getRecmdBookList(
            @PathVariable("recommend") String recommend,
            @RequestHeader("token") String token,
            @Range(min = 1, max = 50, message = "limit必须在[1, 50]区间范围内")
            @RequestParam("limit") Integer limit
    ) throws URISyntaxException {
        List<SimpleBookVO> books;
        if ("personal".equals(recommend)) {
            Long uid = (Long) redis.get(token);
            if (uid != null) {
                User user = userService.getUser(uid);
                if (user != null) {
                    books = bookService.getPersonalRecmdBooks(uid, limit);
                } else {
                    throw new ResourceAccessException("用户不存在");
                }
            } else {
                throw new TokenInvalidException();
            }
        } else if ("popular".equals(recommend)) {
            books = bookService.getHighRatingRecmdBooks(limit);
        } else if ("highRating".equals(recommend)) {
            books = bookService.getPopularRecmdBooks(limit);
        } else {
            throw new ParamErrorException("推荐类型参数错误");
        }
        return books;
    }

    @GetMapping("/list/search")
    @ApiOperation(value = "搜索书籍", notes = "接收查询值，返回搜索到的相关图书列表")
    @ApiImplicitParam(name = "searchValue", value = "搜索值", dataTypeClass = String.class, required = true)
    @ApiResponse(code = 200, message = "成功返回搜索列表")
    public List<SimpleBookVO> getSearchList(
            @RequestParam("searchValue") String searchValue
    ) {
        return bookService.searchBooks(searchValue, 0, 50);
    }

    @GetMapping("/list/read")
    @ApiOperation(value = "获取已读列表", notes = "返回状态为已读的书籍列表")
    @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功返回已读书籍列表"),
            @ApiResponse(code = 401, message = "Token失效")
    })
    public List<SimpleBookVO> getReadList(
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        List<SimpleBookVO> books = null;
        if (uid != null) {
            books = userBookService.getReadList(uid);
        } else {
            throw new TokenInvalidException();
        }
        return books;
    }

    @GetMapping("/list/reading")
    @ApiOperation(value = "获取在读列表", notes = "返回状态为在读的书籍列表")
    @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功返回在读书籍列表"),
            @ApiResponse(code = 401, message = "Token失效")
    })
    public List<SimpleBookVO> getReadingList(
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        List<SimpleBookVO> books = null;
        if (uid != null) {
            books = userBookService.getReadingList(uid);
        } else {
            throw new TokenInvalidException();
        }
        return books;
    }

    @GetMapping("/{bookId}")
    @ApiOperation(value = "获取书籍详情", notes = "接收书籍ISBN号，返回书籍详细信息")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "bookId", value = "书籍ISBN号", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功返回图书详细信息"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 404, message = "书籍不存在")
    })
    public BookDetailVO getBook(
            @PathVariable("bookId") String bookId,
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        BookDetailVO bookDetailVO = null;
        if (uid != null) {
            bookDetailVO = bookService.getBookDetail(bookId, uid);
        } else {
            throw new TokenInvalidException();
        }
        return bookDetailVO;
    }

    @PostMapping("/user-book/{bookId}")
    @ApiOperation(value = "将书籍状态设为在读", notes = "接收书籍ISBN号，将书籍设为在读")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "bookId", value = "书籍ISBN号", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 201, message = "成功将书籍设为在读，并添加到书架"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 403, message = "书籍已在书架")
    })
    public void addReadingBook(
            HttpServletResponse response,
            @PathVariable("bookId") String bookId,
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        if (uid != null) {
            if (!userBookService.exist(bookId, uid)) {
                userBookService.setReading(bookId, uid);
                response.setStatus(201);
            } else {
                throw new ForbiddenException("书籍已在书架");
            }
        } else {
            throw new TokenInvalidException();
        }
    }

    @DeleteMapping("/user-book/{bookId}")
    @ApiOperation(value = "书籍移除书架", notes = "接收图书ISBN号，将对应的图书移除书架")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "bookId", value = "书籍ISBN号", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 204, message = "成功将书籍移除书架"),
            @ApiResponse(code = 401, message = "Token失效")
    })
    public void removeFromMyBooks(
            HttpServletResponse response,
            @PathVariable("bookId") String bookId,
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        if (uid != null) {
            userBookService.remove(bookId, uid);
            response.setStatus(204);
        } else {
            throw new TokenInvalidException();
        }
    }

}

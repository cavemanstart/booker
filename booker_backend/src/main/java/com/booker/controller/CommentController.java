package com.booker.controller;

import com.booker.entity.Comment;
import com.booker.entity.UserBook;
import com.booker.entity.view.CommentVO;
import com.booker.repository.message.UserCollectionsMessageRepository;
import com.booker.service.BookService;
import com.booker.service.CommentService;
import com.booker.service.UserBookService;
import com.booker.utils.RedisOperator;
import com.booker.utils.response.exception.ForbiddenException;
import com.booker.utils.response.exception.ResourcesNotFoundException;
import com.booker.utils.response.exception.TokenInvalidException;
import io.swagger.annotations.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

@Api(tags = "书评接口", description = "与书评相关操作的接口")
@RestController
@RequestMapping("/comment")
@Validated
public class CommentController {

    @Autowired
    private CommentService commentService;

    @Autowired
    private UserBookService userBookService;

    @Autowired
    private UserCollectionsMessageRepository userCollectionsMessageRepository;

    @Autowired
    private RedisOperator redis;

    @GetMapping("/list/{bookId}")
    @ApiOperation(value = "获取书评列表", notes = "接收书籍ISBN号，返回概书籍的书评列表")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "bookId", value = "书籍ISBN号", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功获取评论列表信息"),
            @ApiResponse(code = 401, message = "Token失效")
    })
    public List<CommentVO> getCommentList(
            @PathVariable("bookId") String bookId,
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        List<CommentVO> comments = new ArrayList<>();
        if (uid != null) {
            comments = commentService.getBookComments(bookId, uid);
        } else {
            throw new TokenInvalidException();
        }
        return comments;
    }

    @PostMapping("")
    @ApiOperation(value = "发表书评", notes = "接收书籍ISBN号，添加书评，并将书籍状态设为已读")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "bookId", value = "书籍ISBN号", dataTypeClass = String.class, required = true),
            @ApiImplicitParam(name = "comment", value = "书评信息", required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功发表书评，返回新的书评列表"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 403, message = "已经发表过书评，不能重复评论"),
            @ApiResponse(code = 412, message = "数据格式错误")
    })
    public List<CommentVO> addComment(
            HttpServletResponse response,
            @RequestHeader("token") String token,
            @RequestParam("bookId") String bookId,
            @Validated
            @RequestBody Comment comment
    ) {
        Long uid = (Long) redis.get(token);
        List<CommentVO> comments = null;
        if (uid != null) {
            if (!commentService.exist(bookId, uid)) {
                userBookService.setHasRead(bookId, uid);
                comment.setUid(uid);
                commentService.add(bookId, comment);
                comments = commentService.getBookComments(bookId, uid);
                response.setStatus(200);
            } else {
                throw new ForbiddenException("已经发表过书评，不能重复评论");
            }
        } else {
            throw new TokenInvalidException();
        }
        userCollectionsMessageRepository.send(uid, bookId, comment.getRating(), "update");
        return comments;
    }

    @PostMapping("/user-comment")
    @ApiOperation(value = "给书评点赞", notes = "接收书评Id，修改书评点赞数+1")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "commentId", value = "书评ID", dataTypeClass = Long.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 201, message = "点赞成功"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 404, message = "评论不存在")
    })
    public void addCommentLike(
            HttpServletResponse response,
            @RequestHeader("token") String token,
            @RequestParam("commentId") Long commentId
    ) {
        Long uid = (Long) redis.get(token);
        if (uid != null) {
            if (commentService.exist(commentId)) {
                commentService.like(commentId, uid);
                response.setStatus(201);
            } else {
                throw new ResourcesNotFoundException("评论不存在");
            }
        } else {
            throw new TokenInvalidException();
        }
    }

    @DeleteMapping("/user-comment")
    @ApiOperation(value = "给书评取消点赞", notes = "接收书评ID，修改书评点赞数-1")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "commentId", value = "书评ID", dataTypeClass = Long.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 204, message = "取消点赞成功"),
            @ApiResponse(code = 401, message = "Token"),
            @ApiResponse(code = 404, message = "评论不存在")
    })
    public void cancelCommentLike(
            HttpServletResponse response,
            @RequestHeader("token") String token,
            @RequestParam("commentId") Long commentId
    ) {
        Long uid = (Long) redis.get(token);
        if (uid != null) {
            if (commentService.exist(commentId)) {
                commentService.unlike(commentId, uid);
                response.setStatus(204);
            } else {
                throw new ResourcesNotFoundException("评论不存在");
            }
        } else {
            throw new TokenInvalidException();
        }
    }
}

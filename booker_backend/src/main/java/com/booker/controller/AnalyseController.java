package com.booker.controller;

import com.booker.service.AnalyseService;
import com.booker.utils.RedisOperator;
import com.booker.utils.response.exception.TokenInvalidException;
import io.swagger.annotations.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.constraints.Min;
import java.util.ArrayList;
import java.util.List;

@Api(tags = "用户数据分析接口", description = "与用户数据分析有关接口")
@RestController
@RequestMapping("/analysis")
@Validated
public class AnalyseController {

    @Autowired
    private AnalyseService analyseService;

    @Autowired
    private RedisOperator redis;

    @GetMapping("/reading-plan")
    @ApiOperation(value = "获取阅读计划", notes = "返回用户年度阅读计划")
    @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功获取用户阅读计划"),
            @ApiResponse(code = 401, message = "Token失效")
    })
    public int getReadingPlan(
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        int plan = 0;
        if (uid != null) {
            plan = analyseService.getReadingPlan(uid);
        } else {
            throw new TokenInvalidException();
        }
        return plan;
    }

    @PutMapping("/reading-plan")
    @ApiOperation(value = "制定阅读计划", notes = "设置用户年度阅读计划")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "readingPlan", value = "年度阅读计划", dataTypeClass = Integer.class, required = true),
            @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    })
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功修改用户阅读计划"),
            @ApiResponse(code = 401, message = "Token失效"),
            @ApiResponse(code = 412, message = "数据格式错误")
    })
    public void setReadingPlan(
            @RequestHeader("token") String token,
            @Min(value = 0, message = "阅读计划不能小于0")
            @RequestParam("readingPlan") Integer readingPlan
    ) {
        Long uid = (Long) redis.get(token);
        if (uid != null) {
            analyseService.setReadingPlan(uid, readingPlan);
        } else {
            throw new TokenInvalidException();
        }
    }

    @GetMapping("/read-history")
    @ApiOperation(value = "获取每月阅读统计", notes = "返回用户今年到目前为止每月的阅读数数组")
    @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功获取用户阅读历史"),
            @ApiResponse(code = 401, message = "Token失效")
    })
    public List<Integer> getReadHistory(
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        List<Integer> history = null;
        if (uid != null) {
            history = analyseService.getReadHistory(uid);
        } else {
            throw new TokenInvalidException();
        }
        return history;
    }

    @GetMapping("/interest-tags")
    @ApiOperation(value = "获取兴趣标签", notes = "返回用户前10个兴趣标签列表")
    @ApiImplicitParam(name = "token", value = "Token", dataTypeClass = String.class, required = true)
    @ApiResponses({
            @ApiResponse(code = 200, message = "成功获取用户感兴趣标签列表"),
            @ApiResponse(code = 401, message = "Token失效")
    })
    public List<String> getInterestTags(
            @RequestHeader("token") String token
    ) {
        Long uid = (Long) redis.get(token);
        List<String> tags = new ArrayList<>();
        if (uid != null) {
            tags = analyseService.getInterestTags(uid, 10);
        } else {
            throw new TokenInvalidException();
        }
        return tags;
    }

}

package com.booker.service;

import com.booker.entity.Account;
import com.booker.entity.User;
import org.springframework.stereotype.Service;

import java.util.List;

public interface UserService {

    int VALID = 0;
    int NOT_EXIST = 1;
    int WRONG_PWD = 2;

    int checkLoginInfo(String username, String password);

    User getUser(Long uid);

    User getUser(String email);

    Long getUid(String username);

    User add(User user);
    
    User update(User user) throws IllegalAccessException;

    boolean exist(String email);

    List<String> getAllTags();

    List<String> getAllIndustry();

    void updatePassword(Long uid, String password);
}

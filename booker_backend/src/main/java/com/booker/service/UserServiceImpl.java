package com.booker.service;

import com.booker.entity.Account;
import com.booker.entity.Industry;
import com.booker.entity.Tag;
import com.booker.entity.User;
import com.booker.repository.AccountRepository;
import com.booker.repository.IndustryRepository;
import com.booker.repository.TagRepository;
import com.booker.repository.UserRepository;
import com.booker.repository.message.UsersDataMessageRepository;
import com.booker.utils.response.exception.ParamErrorException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.regex.Pattern;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    UserRepository userRepository;

    @Autowired
    AccountRepository accountRepository;

    @Autowired
    TagRepository tagRepository;

    @Autowired
    IndustryRepository industryRepository;

    @Autowired
    private UsersDataMessageRepository usersDataMessageRepository;

    private static boolean matchUsername(String str) {
        Pattern pattern = Pattern.compile("^\\d{6,16}$");
        return pattern.matcher(str).matches();
    }

    private static boolean matchEmail(String str) {
        Pattern pattern = Pattern.compile("^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$");
        return pattern.matcher(str).matches();
    }

    private static boolean validatePassword(String str) {
        if (!str.trim().isEmpty()) {
            Pattern pattern = Pattern.compile("^[a-zA-Z0-9]\\w{5,15}$");
            return pattern.matcher(str).matches();
        }
        return false;
    }

    @Override
    /**
     * check the login info if valid
     * @param username username / email of user
     * @param password password of user
     * @return the result of checking the login info
     */
    public int checkLoginInfo(String username, String password) {
        User user = null;
        if (matchUsername(username)) {
            user = userRepository.findByUsername(Long.parseLong(username));
        } else if (matchEmail(username)) {
            user = userRepository.findByEmail(username);
        }
        if (user != null) {
            if (password.equals(user.getPassword())) {
                return VALID;
            } else {
                return WRONG_PWD;
            }
        } else {
            return NOT_EXIST;
        }
    }

    @Override
    public User getUser(Long uid) {
        User user = null;
        Optional<User> result = userRepository.findById(uid);
        if (result.isPresent()) {
            user = result.get();
        }
        return user;
    }

    @Override
    public User getUser(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    public Long getUid(String username) {
        User user = null;
        if (matchUsername(username)) {
            user = userRepository.findByUsername(Long.parseLong(username));
        } else if (matchEmail(username)) {
            user = userRepository.findByEmail(username);
        }
        if (user != null) {
            return user.getUid();
        }
        return null;
    }

    @Override
    public User add(User userInfo) {
        if (!validatePassword(userInfo.getPassword())) {
            throw new ParamErrorException("密码必须由6-16位数字或英文字母组成");
        }
        Account account = userInfo.getAccount();
        account.setUser(userInfo);
        User user = userRepository.save(userInfo);
        User newUser = getUser(user.getUid());
        usersDataMessageRepository.send(newUser.getUid(), newUser.getAge(), newUser.getSex(), newUser.getTags(), newUser.getIndustry());
        return newUser;
    }

    @Override
    public User update(User user) throws IllegalAccessException {
        User oldUser = getUser(user.getUid());
        for (Field field : User.class.getDeclaredFields()) {
            field.setAccessible(true);
            Object value = field.get(user);
            if (value != null && value.getClass() != Account.class) {
                field.set(oldUser, value);
            }
        }
        User newUser = userRepository.save(oldUser);
        usersDataMessageRepository.send(oldUser.getUid(), oldUser.getAge(), oldUser.getSex(), oldUser.getTags(), oldUser.getIndustry());
        return newUser;
    }

    @Override
    public boolean exist(String email) {
        User user = getUser(email);
        return user != null;
    }

    @Override
    public List<String> getAllTags() {
        List<Tag> tagList = tagRepository.findAll();
        List<String> tags = new ArrayList<>();
        for (Tag tag : tagList) {
            tags.add(tag.getName());
        }
        return tags;
    }

    @Override
    public List<String> getAllIndustry() {
        List<Industry> industryList = industryRepository.findAll();
        List<String> industries = new ArrayList<>();
        for (Industry industry : industryList) {
            industries.add(industry.getName());
        }
        return industries;
    }

    @Override
    public void updatePassword(Long uid, String password) {
        if (!validatePassword(password)) {
            throw new ParamErrorException("密码必须由6-16位数字或英文字母组成");
        }
        userRepository.updatePassword(uid, password);
    }
}

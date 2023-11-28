package com.booker.service;

import com.booker.entity.Book;
import com.booker.entity.User;
import com.booker.repository.CommentRepository;
import com.booker.repository.UserBookRepository;
import com.booker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;

@Service
public class AnalyseServiceImpl implements AnalyseService {

    @Autowired
    UserRepository userRepository;

    @Autowired
    CommentRepository commentRepository;

    @Autowired
    UserBookRepository userBookRepository;

    @Autowired
    BookService bookService;

    @Override
    public int getReadingPlan(Long uid) {
        Optional<User> result = userRepository.findById(uid);
        if (result.isPresent()) {
            User user = result.get();
            return user.getReadingPlan();
        }
        return 0;
    }

    @Override
    public void setReadingPlan(Long uid, Integer readingPlan) {
        userRepository.updateReadingPlanByUid(uid ,readingPlan);
    }

    @Override
    public List<Integer> getReadHistory(Long uid) {
        Calendar calendar = Calendar.getInstance();
        int month = calendar.get(Calendar.MONTH) + 1;
        int year = calendar.get(Calendar.YEAR);
        List<Integer> history = new ArrayList<>();
        for (int i = 1; i <= month; i++) {
            LocalDate start = LocalDate.of(year, i, 1);
            LocalDate end = LocalDate.of(year, i+1, 1);
            history.add(commentRepository.getReadNum(uid, start, end));
        }
        return history;
    }

    @Override
    public List<String> getInterestTags(Long uid, int limit) {
        List<String> tags = new ArrayList<>();

        List<Book> books = userBookRepository.findBookListByUid(uid);

        Map<String, Integer> counter = new HashMap<>();

        for (Book book : books) {
            for (String tag : book.getTags()) {
                if (counter.containsKey(tag)) {
                    counter.put(tag, counter.get(tag) + 1);
                } else {
                    counter.put(tag, 0);
                }
            }
        }

        List<Map.Entry<String, Integer>> list = new ArrayList<>(counter.entrySet());

        list.sort(new Comparator<Map.Entry<String, Integer>>() {
            @Override
            public int compare(Map.Entry<String, Integer> o1, Map.Entry<String, Integer> o2) {
                return o1.getValue().compareTo(o2.getValue());
            }
        });

        for (int i = 0; i < limit && i < list.size(); i++) {
            tags.add(list.get(i).getKey());
        }

        return tags;
    }

}

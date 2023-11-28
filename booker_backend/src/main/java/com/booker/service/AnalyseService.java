package com.booker.service;

import java.util.List;

public interface AnalyseService {
    int getReadingPlan(Long uid);

    void setReadingPlan(Long uid, Integer readingPlan);

    List<Integer> getReadHistory(Long uid);

    List<String> getInterestTags(Long uid, int limit);
}

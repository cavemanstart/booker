package com.booker.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class GlobalConfig {

    @Value("${server.host}")
    private static String host;

    public static String getHost() {
        return host;
    }

}

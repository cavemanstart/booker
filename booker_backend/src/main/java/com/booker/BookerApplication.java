package com.booker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import springfox.documentation.oas.annotations.EnableOpenApi;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@EnableOpenApi
@EnableJpaAuditing
@SpringBootApplication
public class BookerApplication {
    public static void main(String[] args) {
        SpringApplication.run(BookerApplication.class, args);
    }
}

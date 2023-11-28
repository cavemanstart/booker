package com.booker.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Contact;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;

@Data
@Configuration
@ConfigurationProperties("swagger")
public class SwaggerConfig implements WebMvcConfigurer {

    private String title;

    private String version;

    private String description;

    private String author;

    private String testHost;

    private String controllerPath;

    @Bean
    public Docket createDocket(Environment environment) {
        Profiles profiles = Profiles.of("dev", "test");
        boolean swaggerEnable = environment.acceptsProfiles(profiles);
        return new Docket(DocumentationType.OAS_30)
                .enable(swaggerEnable)
                .apiInfo(this.apiInfo())
                .host(testHost)
                .select()
                .apis(RequestHandlerSelectors.basePackage(controllerPath))
                .paths(PathSelectors.any())
                .build();
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title(title)
                .description(description)
                .contact(new Contact(author, null, null))
                .version(version)
                .build();
    }
}

package com.booker.config;

import org.springframework.amqp.core.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {
    @Bean
    public Queue realtimeQueue() {
        return QueueBuilder.durable("realtime").build();
    }
    @Bean
    public Queue onlineTrainQueue(){
        return QueueBuilder.durable("onlinetraining").build();
    }
    @Bean
    public Queue usersDataQueue(){
        return QueueBuilder.durable("usersData").build();
    }
    @Bean
    public Queue booksDataQueue(){
        return QueueBuilder.durable("booksData").build();
    }
    @Bean
    public Queue testQueue(){
        return QueueBuilder.durable("test").build();
    }
    @Bean
    public DirectExchange directExchange() {
        return new DirectExchange("amq.direct", true, false);
    }
    @Bean
    public Binding bindingTestQueue() {
        return BindingBuilder.bind(testQueue()).to(directExchange()).with("test");
    }
    @Bean
    public Binding bindingRealTimeQueue() {
        return BindingBuilder.bind(realtimeQueue()).to(directExchange()).with("realtime");
    }
    @Bean
    public Binding bindingOnlineTrainQueue() {
        return BindingBuilder.bind(onlineTrainQueue()).to(directExchange()).with("onlinetraining");
    }
    @Bean
    public Binding bindingUsersDataQueue() {
        return BindingBuilder.bind(usersDataQueue()).to(directExchange()).with("usersData");
    }
    @Bean
    public Binding bindingBooksDataQueue() {
        return BindingBuilder.bind(booksDataQueue()).to(directExchange()).with("booksData");
    }
}

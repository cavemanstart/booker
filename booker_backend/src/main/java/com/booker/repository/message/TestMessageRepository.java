package com.booker.repository.message;
import java.util.UUID;

import org.springframework.amqp.rabbit.connection.CorrelationData;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class TestMessageRepository {
    private RabbitTemplate testMessageTemplate;

    @Autowired
    public void setTestMessageTemplate(RabbitTemplate testMessageTemplate) {
        this.testMessageTemplate = testMessageTemplate;
    }

    public void send(String message) {
        String exchange = "amq.direct";
        String routingKey = "test";
        CorrelationData correlationId = new CorrelationData(UUID.randomUUID().toString());
        System.out.println("start sending : " + message);
        testMessageTemplate.convertAndSend(exchange, routingKey, message, correlationId);
    }
}

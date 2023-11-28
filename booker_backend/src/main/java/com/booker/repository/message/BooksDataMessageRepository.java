package com.booker.repository.message;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.amqp.rabbit.connection.CorrelationData;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public class BooksDataMessageRepository {
    private RabbitTemplate booksDataMessageTemplate;

    @Autowired
    public void setBooksDataMessageTemplate(RabbitTemplate booksDataMessageTemplate) {
        this.booksDataMessageTemplate = booksDataMessageTemplate;
    }

    private static class BooksDataMessage{
        private final Long bid;
        private final String[] tags;
        private final Integer degree;

        public BooksDataMessage(Long bid, String[] tags, Integer degree) {
            this.bid = bid;
            this.tags = tags;
            this.degree = degree;
        }

        public Long getBid() {
            return bid;
        }

        public String[] getTags() {
            return tags;
        }

        public Integer getDegree() {
            return degree;
        }

        public String toJson() throws JsonProcessingException {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.writeValueAsString(this);
        }
    }

    public void send(String bookId,String[] tags,Double degree) {
        String exchange = "amq.direct";
        String routingKey = "booksData";
        CorrelationData correlationId = new CorrelationData(UUID.randomUUID().toString());
        BooksDataMessage booksDataMessage = new BooksDataMessage(Long.parseLong(bookId),tags,degree.intValue());
        try {
            String message = booksDataMessage.toJson();
            booksDataMessageTemplate.convertAndSend(exchange, routingKey,message, correlationId);
            System.out.println(message);
        } catch (Exception exception){
            exception.printStackTrace();
        }
    }
}

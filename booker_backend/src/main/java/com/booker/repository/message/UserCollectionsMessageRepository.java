package com.booker.repository.message;

import com.booker.entity.User;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.MessageProperties;
import org.springframework.amqp.rabbit.connection.CorrelationData;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.nio.charset.StandardCharsets;
import java.util.UUID;

@Repository
public class UserCollectionsMessageRepository {
    private final RabbitTemplate userCollectionsMessageTemplate;

    @Autowired
    public UserCollectionsMessageRepository(RabbitTemplate userCollectionsMessageTemplate) {
        this.userCollectionsMessageTemplate = userCollectionsMessageTemplate;
    }
    private static class ScoreMessage{
        private final Long uid;
        private final Long bid;
        private final Integer score;

        public ScoreMessage(Long uid, Long bid, Integer score) {
            this.uid = uid;
            this.bid = bid;
            this.score = score;
        }

        public Long getUid() {
            return uid;
        }

        public Long getBid() {
            return bid;
        }

        public Integer getScore() {
            return score;
        }
        public String toJson() throws JsonProcessingException {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.writeValueAsString(this);
        }
    }

    public void send(Long username,String bookId,Double score,String command) {
        String exchange = "amq.direct";
        String routingKey = "onlinetraining";
        CorrelationData correlationId = new CorrelationData(UUID.randomUUID().toString());
        ScoreMessage scoreMessage =new ScoreMessage(username,Long.parseLong(bookId),score.intValue());
        try {
            String body = scoreMessage.toJson();
            MessageProperties messageProperties = new MessageProperties();
            messageProperties.setHeader("command",command);
            Message message = new Message(body.getBytes(StandardCharsets.UTF_8),messageProperties);
            userCollectionsMessageTemplate.send(exchange, routingKey,message, correlationId);
            System.out.println(message);
        } catch (Exception exception){
            exception.printStackTrace();
        }
    }
}

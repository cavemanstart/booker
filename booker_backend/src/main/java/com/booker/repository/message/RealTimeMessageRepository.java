package com.booker.repository.message;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.amqp.rabbit.connection.CorrelationData;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public class RealTimeMessageRepository {
    private RabbitTemplate historyMessageTemplate;

    @Autowired
    public void setHistoryMessageTemplate(RabbitTemplate historyMessageTemplate) {
        this.historyMessageTemplate = historyMessageTemplate;
    }

    private static class HistoryMessage{
        private final Long uid;
        private final Long bid;

        public HistoryMessage(Long uid, Long bid) {
            this.uid = uid;
            this.bid = bid;
        }

        public Long getUid() {
            return uid;
        }

        public Long getBid() {
            return bid;
        }

        public String toJson() throws JsonProcessingException {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.writeValueAsString(this);
        }
    }

    public void send(Long username,String bookId) {
        String exchange = "amq.direct";
        String routingKey = "realtime";
        CorrelationData correlationId = new CorrelationData(UUID.randomUUID().toString());
        HistoryMessage historyMessage = new HistoryMessage(username,Long.parseLong(bookId));
        try {
            String message = historyMessage.toJson();
            historyMessageTemplate.convertAndSend(exchange, routingKey,message, correlationId);
            System.out.println(message);
        } catch (Exception exception){
            exception.printStackTrace();
        }
    }
}

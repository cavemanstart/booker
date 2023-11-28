package com.booker.repository.message;

import com.fasterxml.jackson.core.JsonProcessingException;
import org.springframework.amqp.rabbit.connection.CorrelationData;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.UUID;

@Repository
public class UsersDataMessageRepository {
    private RabbitTemplate usersDataMessageTemplate;

    @Autowired
    public void setUsersDataMessageTemplate(RabbitTemplate usersDataMessageTemplate) {
        this.usersDataMessageTemplate = usersDataMessageTemplate;
    }

    private static class UsersDataMessage{
        private final Long uid;
        private final Integer age;
        private final String gender;
        private final String occupation;
        private final String[] favors;

        public UsersDataMessage(Long uid, Integer age, String gender, String occupation, String[] favors) {
            this.uid = uid;
            this.age = age;
            this.gender = gender;
            this.occupation = occupation;
            this.favors = favors;
        }

        public Long getUid() {
            return uid;
        }

        public Integer getAge() {
            return age;
        }

        public String getGender() {
            return gender;
        }

        public String getOccupation() {
            return occupation;
        }

        public String[] getFavors() {
            return favors;
        }

        public String toJson() throws JsonProcessingException {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.writeValueAsString(this);
        }

    }

    public void send(Long username,Integer age,Integer sex,String[] tags, String industry) {
        String exchange = "amq.direct";
        String routingKey = "usersData";
        CorrelationData correlationId = new CorrelationData(UUID.randomUUID().toString());
        String gender = null;
        if(sex==0)
            gender = "M";
        else if(sex==1)
            gender = "F";
        else
            throw new IllegalArgumentException("sex must be either 0 or 1");
        UsersDataMessage usersDataMessage = new UsersDataMessage(username,age,gender,industry,tags);
        try {
            String message = usersDataMessage.toJson();
            usersDataMessageTemplate.convertAndSend(exchange, routingKey,message, correlationId);
            System.out.println(message);
        } catch (Exception exception){
            exception.printStackTrace();
        }
    }
}

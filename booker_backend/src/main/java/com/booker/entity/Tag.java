package com.booker.entity;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import javax.validation.constraints.*;
import lombok.Data;
import org.hibernate.annotations.DynamicInsert;

import javax.persistence.*;

@ApiModel("标签")
@Data
@Entity
@DynamicInsert
@Table(name = "tag")
public class Tag {

    @ApiModelProperty(value = "标签ID，主键", required = true, example = "1")
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "tag_id", columnDefinition = "smallserial")
    private Short id;

    @ApiModelProperty(value = "标签名", required = true, example = "计算机")
    @Column(name = "tag_name", nullable = false, unique = true, length = 10)
    private String name;

}

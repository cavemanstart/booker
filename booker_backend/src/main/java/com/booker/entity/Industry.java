package com.booker.entity;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.persistence.*;

@ApiModel("行业")
@Data
@Entity
@Table(name = "industry")
public class Industry {

    @ApiModelProperty(value = "行业ID，主键", required = true, example = "1")
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "industry_id", columnDefinition = "smallserial")
    private Short id;

    @ApiModelProperty(value = "名称", required = true, example = "计算机")
    @Column(name = "industry_name", unique = true)
    private String name;
}

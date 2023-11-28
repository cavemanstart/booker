package com.booker.entity.view;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Value;

@Data
@NoArgsConstructor
@ApiModel("图书评分统计信息")
public class RatingStatistics {
    @ApiModelProperty(value = "平均评分")
    Double meanRating;

    @ApiModelProperty(value = "一星比例")
    Double oneStar;

    @ApiModelProperty(value = "二星比例")
    Double twoStar;

    @ApiModelProperty(value = "三星比例")
    Double threeStar;

    @ApiModelProperty(value = "四星比例")
    Double fourStar;

    @ApiModelProperty(value = "五星比例")
    Double fiveStar;

    @ApiModelProperty(value = "评分人数")
    Long sumOfRating;

    public RatingStatistics(Double meanRating, Long sumOfRating) {
        this.meanRating = meanRating==null?0:meanRating;
        this.sumOfRating = sumOfRating==null?0:sumOfRating;
    }

    public Double getOneStar() {
        return oneStar==null?0:oneStar;
    }

    public Double getTwoStar() {
        return twoStar==null?0:twoStar;
    }

    public Double getThreeStar() {
        return threeStar==null?0:threeStar;
    }

    public Double getFourStar() {
        return fourStar==null?0:fourStar;
    }

    public Double getFiveStar() {
        return fiveStar==null?0:fiveStar;
    }
}

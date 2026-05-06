package com.HazardNet.HazardNet.dto;

import lombok.Data;

@Data
public class ResourceNeedDto {

    private Long id;

    private Integer food_qty;

    private String medicine_qty;

    private String clothes_qty;

    private String price_qty;

    private String urgency_level;

    private Long rescueCampId;

}

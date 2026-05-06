package com.HazardNet.HazardNet.dto;


import lombok.Data;

import java.util.Date;

@Data
public class OrphanGroupDto {

    private Long id;

    private String name;

    private Integer num_of_kids;

    private Double location_lat;

    private Double location_lon;

    private Date created_at;

    private Long rescueCampId;
}

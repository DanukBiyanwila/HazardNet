package com.HazardNet.HazardNet.dto;

import lombok.Data;

import java.util.List;

@Data
public class HomeDto {

    private Long id;

    private String address;

    private Double location_lat;

    private Double location_lon;

    private Integer family_count;

    private Double near_river_km;

    private Double elevation;

    private String created_at;

    private String imageUrl;

    private List<Long> userIds;

    private List<Long> homeRiskStatusIds;
}
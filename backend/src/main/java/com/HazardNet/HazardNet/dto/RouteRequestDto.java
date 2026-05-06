package com.HazardNet.HazardNet.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class RouteRequestDto {

    private Long id;

    private Double start_lat;

    private Double start_lon;

    private Double end_lat;

    private Double end_lon;

    private LocalDateTime requested_time;

    private String status;

    private Long userId;

    private List<Long> routeHazardCheckIds;
}
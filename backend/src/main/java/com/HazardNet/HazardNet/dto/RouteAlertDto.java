package com.HazardNet.HazardNet.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class RouteAlertDto {

    private Long id;

    private LocalDateTime alert_time;

    private String message;

    private String alert_type;

    private Boolean is_know;

    private Long userId;

    private Long routeHazardCheckId;
}
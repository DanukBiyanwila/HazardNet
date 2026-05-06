package com.HazardNet.HazardNet.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class RouteHazardCheckDto {

    private Long id;

    private LocalDateTime detected_time;

    private String risk_level;

    private Double distance_to_hazard_m;

    private Long hazardAreaId;

    private List<Long> routeRequestIds;

    private List<Long> routeAlertIds;
}
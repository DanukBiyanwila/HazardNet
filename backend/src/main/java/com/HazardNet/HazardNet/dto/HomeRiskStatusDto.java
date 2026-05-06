package com.HazardNet.HazardNet.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class HomeRiskStatusDto {

    private Long id;

    private Integer flood_risk_level;

    private Integer landslide_risk;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime created_at;

    private Long homeId;

}
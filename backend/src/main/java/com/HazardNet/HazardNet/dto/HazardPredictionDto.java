package com.HazardNet.HazardNet.dto;

import lombok.Data;

@Data
public class HazardPredictionDto {

    private Long id;

    private String predicted_type;

    private String predicted_risk_level;

    private String rainfall_mm;

    private String soil_moisture;

    private String river_level;

    private String created_at;

    private String confidence_score;

    private Double location_lat;

    private Double location_lon;

}

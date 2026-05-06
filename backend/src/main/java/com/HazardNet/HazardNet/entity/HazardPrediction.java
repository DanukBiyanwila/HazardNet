package com.HazardNet.HazardNet.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "hazard_prediction")
public class HazardPrediction {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "predicted_type")
    private String predicted_type;

    @Column(name = "predicted_risk_level")
    private String predicted_risk_level;

    @Column(name = "rainfall_mm")
    private String rainfall_mm;

    @Column(name = "soil_moisture")
    private String soil_moisture;

    @Column(name = "river_level")
    private String river_level;

    @Column(name = "created_at")
    private String created_at;

    @Column(name = "confidence_score")
    private String confidence_score;

    @Column(name = "location_lat")
    private Double location_lat;

    @Column(name = "location_lon")
    private Double location_lon;






}

package com.HazardNet.HazardNet.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "emergency_reports")
public class EmergencyReports {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "emergency_type")
    private String emergency_type;

    @Column(name = "location_lat")
    private Double location_lat;

    @Column(name = "location_lon")
    private Double location_lon;

    @Column(name = "status")
    private String status;

    @Column(name = "created_at")
    private String created_at;

    @Column(name = "is_show")
    private Boolean is_show;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = true)
    @JsonIgnoreProperties("emergencyReports")
    private User user;

}
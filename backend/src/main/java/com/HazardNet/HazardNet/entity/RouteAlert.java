package com.HazardNet.HazardNet.entity;


import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "route_alert")
public class RouteAlert {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "alert_time")
    private LocalDateTime alert_time;

    @Column(name = "message")
    private String message;

    @Column(name = "alert_type")
    private String alert_type;

    @Column(name = "is_know")
    private Boolean is_know;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnoreProperties({
            "routeAlerts",
            "donations",
            "homes",
            "hazardAreas"
    })
    private User user;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_hazard_check_id", nullable = false)
    @JsonIgnoreProperties("routeAlerts")
    private RouteHazardCheck routeHazardCheck;


}

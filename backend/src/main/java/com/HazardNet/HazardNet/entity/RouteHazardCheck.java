package com.HazardNet.HazardNet.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "route_hazard_check")
public class RouteHazardCheck {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "detected_time")
    private LocalDateTime detected_time;

    @Column(name = "risk_level")
    private String risk_level;

    @Column(name = "distance_to_hazard_m")
    private Double distance_to_hazard_m;

    @OneToMany(mappedBy = "routeHazardCheck", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties("routeHazardCheck")
    private List<RouteAlert> routeAlerts = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hazard_area_id", nullable = false)
    @JsonIgnoreProperties({
            "routeHazardChecks",
            "hazardHistories",
            "hazardPredictions",
            "users"
    })
    private HazardArea hazardArea;

    @ManyToMany(mappedBy = "routeHazardChecks")
    @JsonIgnoreProperties("routeHazardChecks")
    private List<RouteRequest> routeRequests = new ArrayList<>();
}

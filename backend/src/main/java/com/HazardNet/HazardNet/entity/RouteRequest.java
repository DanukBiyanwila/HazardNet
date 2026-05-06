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
@Table(name = "route_request")
public class RouteRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "start_lat")
    private Double start_lat;

    @Column(name = "start_lon")
    private Double start_lon;

    @Column(name = "end_lat")
    private Double end_lat;

    @Column(name = "end_lon")
    private Double end_lon;

    @Column(name = "requested_time")
    private LocalDateTime requested_time;

    @Column(name = "status")
    private String status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnoreProperties({"routeRequests"})
    private User user;

    @ManyToMany
    @JoinTable(
            name = "route_request_hazard_check",
            joinColumns = @JoinColumn(name = "route_request_id"),
            inverseJoinColumns = @JoinColumn(name = "route_hazard_check_id")
    )
    @JsonIgnoreProperties("routeRequests")
    private List<RouteHazardCheck> routeHazardChecks = new ArrayList<>();

}

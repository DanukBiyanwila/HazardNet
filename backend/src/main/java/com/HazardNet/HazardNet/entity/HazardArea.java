package com.HazardNet.HazardNet.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "hazard_area")
public class HazardArea {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "name")
    private String name;

    @Column(name = "location_lat")
    private Double location_lat;

    @Column(name = "location_lon")
    private Double location_lon;

    @Column(name = "city")
    private String city;

    @Column(name = "district")
    private String district;

    @Column(name = "created_at")
    private Date created_at;

    @Column(name = "severity_level")
    private String severity_level;

    @Column(name = "radius_meters")
    private String radius_meters;


    @ManyToMany(mappedBy = "hazardAreas")
    private List<User> users = new ArrayList<>();

    @OneToMany(mappedBy = "hazardArea", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<HazardHistory> hazardHistories = new ArrayList<>();

    @OneToMany(mappedBy = "hazardArea", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties("hazardArea")
    private List<RouteHazardCheck> routeHazardChecks = new ArrayList<>();

}

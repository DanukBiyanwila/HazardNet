package com.HazardNet.HazardNet.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "home")
public class Home {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "address")
    private String address;

    @Column(name = "location_lat")
    private Double location_lat;

    @Column(name = "location_lon")
    private Double location_lon;

    @Column(name = "family_count")
    private Integer family_count;

    @Column(name = "near_river_km")
    private Double near_river_km;

    @Column(name = "elevation")
    private Double elevation;

    @Column(name = "created_at")
    private String created_at;

    @Column(name = "image_url")
    private String imageUrl;


    @ManyToMany
    @JoinTable(
            name = "user_home",
            joinColumns = @JoinColumn(name = "home_id"),
            inverseJoinColumns = @JoinColumn(name = "user_id")
    )
    @JsonIgnoreProperties("homes")
    private List<User> users = new ArrayList<>();

    @OneToMany(mappedBy = "home", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties("home")
    private List<HomeRiskStatus> riskStatuses = new ArrayList<>();

}

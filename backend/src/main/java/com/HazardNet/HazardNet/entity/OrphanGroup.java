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
@Table(name = "orphan_group")
public class OrphanGroup {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "name")
    private String name;

    @Column(name = "num_of_kids")
    private Integer num_of_kids;

    @Column(name = "location_lat")
    private Double location_lat;

    @Column(name = "location_lon")
    private Double  location_lon;

    @Column(name = "created_at")
    private Date created_at;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rescue_camp_id", nullable = false) // Foreign key column
    private RescueCamp rescueCamp;

    @OneToMany(mappedBy = "orphanGroup", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties("orphanGroup")
    private List<DonationMatch> donationMatches = new ArrayList<>();



}

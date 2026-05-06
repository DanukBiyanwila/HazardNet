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
@Table(name = "rescue_camp")
public class RescueCamp {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "name")
    private String name;

    @Column(name = "address")
    private String address;

    @Column(name = "tp_no")
    private String tp_no;

    @Column(name = "location_lat")
    private Double location_lat;

    @Column(name = "location_lon")
    private Double location_lon;

    @Column(name = "capacity")
    private Integer capacity;

    @Column(name = "current_people_count")
    private Integer current_people_count;

    @Column(name = "people_image_url")
    private String people_image_url;


    @OneToMany(mappedBy = "rescueCamp", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties({"rescueCamp"}) // Prevents circular reference on this side
    private List<OrphanGroup> orphanGroups = new ArrayList<>();


    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "manager_user_id", nullable = false)
    @JsonIgnoreProperties({"rescueCamps"})
    private User manager;

    @OneToMany(mappedBy = "rescueCamp", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties({"rescueCamp"})
    private List<ResourceNeed> resourceNeeds = new ArrayList<>();

    @OneToMany(mappedBy = "rescueCamp", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties("rescueCamp")
    private List<DonationMatch> donationMatches = new ArrayList<>();


}

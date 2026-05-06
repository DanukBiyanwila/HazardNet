package com.HazardNet.HazardNet.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "resource_need")
public class ResourceNeed {


    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "food_qty")
    private Integer food_qty;

    @Column(name = "medicine_qty")
    private String medicine_qty;

    @Column(name = "clothes_qty")
    private String clothes_qty;

    @Column(name = "urgency_level")
    private String urgency_level;

    @Column(name = "price_qty")
    private String price_qty;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rescue_camp_id")  // FK column in resource_need table
    @JsonIgnoreProperties({"resourceNeeds"})
    private RescueCamp rescueCamp;






}

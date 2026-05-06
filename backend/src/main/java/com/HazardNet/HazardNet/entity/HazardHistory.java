package com.HazardNet.HazardNet.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "hazard_history")
public class HazardHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "hazard_type")
    private String hazard_type;

    @Column(name = "severity_level")
    private Integer severity_level;

    @Column(name = "occurred_time")
    private String occurred_time;

    @Column(name = "dis")
    private String dis;

    @Column(name = "death_count")
    private Integer death_count;

    @Column(name = "house_damage")
    private Integer house_damage;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hazard_area_id")
    private HazardArea hazardArea;

}

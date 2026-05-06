package com.HazardNet.HazardNet.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "emergency_service")
public class EmergencyService {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "name")
    private String name;

    @Column(name = "service_type")
    private String service_type;

    @Column(name = "location_lat")
    private Double location_lat;

    @Column(name = "location_lon")
    private Double location_lon;

    @Column(name = "phone")
    private String phone;

    @Column(name = "address")
    private String address;

}

package com.HazardNet.HazardNet.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "media_report")
public class MediaReport {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "title")
    private String title;

    @Column(name = "dis")
    private String dis;

    @Column(name = "media_url")
    private String media_url;

    @Column(name = "location_lon")
    private Double location_lon;

    @Column(name = "location_lat")
    private Double location_lat;

    @Column(name = "upload_time")
    private LocalDateTime upload_time;

    @Column(name = "hazard_type")
    private String hazard_type;

    @Column(name = "status")
    private String status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnoreProperties({
            "mediaReports",
            "routeAlerts",
            "donations",
            "homes",
            "hazardAreas"
    })
    private User user;

    @OneToOne(mappedBy = "mediaReport", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnoreProperties("mediaReport")
    private MediaVerification mediaVerification;


}

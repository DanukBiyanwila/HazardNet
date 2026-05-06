package com.HazardNet.HazardNet.entity;


import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "media_verification")
public class MediaVerification {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "authenticity_score")
    private Double authenticity_score;

    @Column(name = "ml_detected_fake")
    private Boolean ml_detected_fake;

    @Column(name = "ml_detected_hazard")
    private Boolean ml_detected_hazard;

    @Column(name = "verified_time")
    private LocalDateTime verified_time;

    @Column(name = "is_approved")
    private Boolean is_approved;

    @Column(name = "rejection_reason")
    private String rejection_reason;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnoreProperties({
            "mediaVerifications",
            "mediaReports",
            "routeAlerts",
            "donations",
            "homes",
            "hazardAreas"
    })
    private User user;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "media_report_id", nullable = false, unique = true)
    @JsonIgnoreProperties("mediaVerification")
    private MediaReport mediaReport;

}

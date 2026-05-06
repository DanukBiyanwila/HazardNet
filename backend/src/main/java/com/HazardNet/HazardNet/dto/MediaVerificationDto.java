package com.HazardNet.HazardNet.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MediaVerificationDto {

    private Long id;

    private Double authenticity_score;

    private Boolean ml_detected_fake;

    private Boolean ml_detected_hazard;

    private LocalDateTime verified_time;

    private Boolean is_approved;

    private String rejection_reason;

    private Long userId;

    private Long mediaReportId;

}
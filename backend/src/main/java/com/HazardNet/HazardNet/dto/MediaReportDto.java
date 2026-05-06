package com.HazardNet.HazardNet.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MediaReportDto {

    private Long id;

    private String title;

    private String dis;

    private String media_url;

    private Double location_lon;

    private Double location_lat;

    private LocalDateTime upload_time;

    private String hazard_type;

    private String status;

    private Long userId;

    private Long mediaVerificationId;
}
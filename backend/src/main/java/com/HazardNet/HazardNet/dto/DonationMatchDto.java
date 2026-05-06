package com.HazardNet.HazardNet.dto;


import lombok.Data;

import java.time.LocalDateTime;

import java.util.List;

@Data
public class DonationMatchDto {

    private Long id;

    private Integer matched_quantity;

    private LocalDateTime match_date;


    private List<Long> donationIds;

    private Long orphanGroupId;

    private Long rescueCampId;
}

